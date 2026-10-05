{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.services.windows-sriov-vm;
  stateDir = "/var/lib/windows-sriov-vm";
  runtimeDir = "/run/windows-sriov-vm";
  vcpuList = concatStringsSep "," (map toString cfg.vcpuCPUs);

  gfxSriovToolkit = pkgs.stdenvNoCC.mkDerivation {
    pname = "intel-gfx-sriov-toolkit";
    version = "2026-04cfba7";
    src = inputs.gfx-sriov-toolkit;
    nativeBuildInputs = [ pkgs.makeWrapper ];
    patches = [ ./gfx-sriov-driver-override.patch ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec $out/share/gfx-sriov-toolkit
      cp scripts/provision-sriov.sh $out/libexec/
      cp -r config test-suite $out/share/gfx-sriov-toolkit/
      patchShebangs $out/libexec $out/share/gfx-sriov-toolkit/test-suite
      wrapProgram $out/libexec/provision-sriov.sh \
        --prefix PATH : ${
          lib.makeBinPath [
            pkgs.coreutils
            pkgs.gawk
            pkgs.gnugrep
            pkgs.gnused
            pkgs.kmod
            pkgs.libxml2
            pkgs.pciutils
            pkgs.util-linux
          ]
        }
      runHook postInstall
    '';
  };

  vfProvision = pkgs.writeShellApplication {
    name = "windows-sriov-vf-provision";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.kmod
    ];
    text = ''
      set -euo pipefail
      pf=/sys/bus/pci/devices/${cfg.gpuPFAddress}
      profile=${gfxSriovToolkit}/share/gfx-sriov-toolkit/config/vgpu-profile/igpu-idv-profile.xml

      test -d "$pf" || { echo "GPU PF ${cfg.gpuPFAddress} is missing" >&2; exit 1; }
      test "$(basename "$(readlink -f "$pf/driver")")" = xe || {
        echo "GPU PF ${cfg.gpuPFAddress} must remain bound to xe" >&2
        exit 1
      }

      ${gfxSriovToolkit}/libexec/provision-sriov.sh \
        --num-vfs 1 --pci-device ${cfg.gpuPFAddress} --config "$profile"

      test "$(cat "$pf/sriov_numvfs")" = 1
      vf=$(basename "$(readlink -f "$pf/virtfn0")")
      test "$(basename "$(readlink -f "/sys/bus/pci/devices/$vf/driver")")" = vfio-pci

      for device in ${cfg.windowsNVMeAddress} "$vf"; do
        group=$(basename "$(readlink -f "/sys/bus/pci/devices/$device/iommu_group")")
        node=/dev/vfio/$group
        test -c "$node" || { echo "Missing VFIO group node $node for $device" >&2; exit 1; }
        chown root:windows-vm "$node"
        chmod 0660 "$node"
      done
      chown root:windows-vm /dev/vfio/vfio
      chmod 0660 /dev/vfio/vfio

      install -m 0644 /dev/null ${runtimeDir}/provisioned
      printf '%s\n' "$vf" > ${runtimeDir}/gpu-vf
    '';
  };

  windowsVm = pkgs.writeShellApplication {
    name = "windows-vm";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.passt
      pkgs.pciutils
      pkgs.procps
      pkgs.qemu_kvm
      pkgs.socat
      pkgs.swtpm
      pkgs.util-linux
    ];
    text = ''
      set -euo pipefail

      state=${stateDir}
      run=${runtimeDir}
      qemu_pid="$state/qemu.pid"
      qmp_sock="$state/qmp.sock"
      qga_sock="$state/qga.sock"
      passt_pid="$state/passt.pid"
      passt_sock="$state/passt.sock"
      swtpm_pid="$state/swtpm.pid"
      swtpm_sock="$state/swtpm.sock"
      vf_file="$run/gpu-vf"
      nvme=${cfg.windowsNVMeAddress}
      pf=${cfg.gpuPFAddress}

      die() { echo "windows-vm: $*" >&2; exit 1; }
      alive() { test -f "$1" && kill -0 "$(cat "$1")" 2>/dev/null; }
      driver() {
        local link="/sys/bus/pci/devices/$1/driver"
        test -L "$link" && basename "$(readlink -f "$link")"
      }
      iommu_group() {
        basename "$(readlink -f "/sys/bus/pci/devices/$1/iommu_group")"
      }
      isolated() {
        local device=$1 group count
        group=$(iommu_group "$device") || return 1
        count=$(find "/sys/kernel/iommu_groups/$group/devices" -mindepth 1 -maxdepth 1 | wc -l)
        test "$count" -eq 1
      }
      windows_disk_mounted() {
        local sysfs=/sys/bus/pci/devices/$nvme block_path block
        for block_path in "$sysfs"/nvme/nvme*/nvme*n*; do
          test -e "$block_path" || continue
          block=''${block_path##*/}
          test -b "/dev/$block" || continue
          if lsblk -nrpo MOUNTPOINT "/dev/$block" | grep -q '[^[:space:]]'; then
            return 0
          fi
        done
        return 1
      }
      qmp() {
        printf '%s\n%s\n' '{"execute":"qmp_capabilities"}' "$1" |
          socat -t 2 - UNIX-CONNECT:"$qmp_sock"
      }
      stop_helpers() {
        if alive "$passt_pid"; then kill "$(cat "$passt_pid")" 2>/dev/null || true; fi
        if alive "$swtpm_pid"; then kill "$(cat "$swtpm_pid")" 2>/dev/null || true; fi
        rm -f "$passt_sock" "$swtpm_sock"
      }
      preflight() {
        test "$EUID" -ne 0 || die "refusing to run QEMU as root; use the configured VM owner"
        test -e "$run/provisioned" || die "SR-IOV provisioning service did not complete"
        test -r "$vf_file" || die "provisioned GPU VF address is unavailable"
        vf=$(cat "$vf_file")

        test -d "/sys/bus/pci/devices/$pf" || die "GPU PF $pf is missing"
        test "$(driver "$pf")" = xe || die "GPU PF $pf is not bound to xe"
        test "$(cat "/sys/bus/pci/devices/$pf/sriov_numvfs")" = 1 || die "GPU PF does not expose exactly one VF"
        test "$(basename "$(readlink -f "/sys/bus/pci/devices/$pf/virtfn0")")" = "$vf" || die "virtfn0 changed since provisioning"
        test "$(driver "$vf")" = vfio-pci || die "GPU VF $vf is not bound to vfio-pci"
        test "$(cat "/sys/bus/pci/devices/$vf/driver_override")" = vfio-pci || die "GPU VF lacks the vfio-pci driver override"

        test -d "/sys/bus/pci/devices/$nvme" || die "Windows NVMe controller $nvme is missing"
        windows_disk_mounted && die "the Windows NVMe or one of its partitions is mounted"
        pci_id=$(printf '%s:%s' \
          "$(sed 's/^0x//' "/sys/bus/pci/devices/$nvme/vendor")" \
          "$(sed 's/^0x//' "/sys/bus/pci/devices/$nvme/device")")
        test "$pci_id" = ${cfg.windowsNVMeId} || die "Windows NVMe ID is $pci_id, expected ${cfg.windowsNVMeId}"
        test "$(driver "$nvme")" = vfio-pci || die "Windows NVMe $nvme is not bound to vfio-pci (it may still be mounted)"

        isolated "$vf" || die "GPU VF $vf does not have an isolated IOMMU group"
        isolated "$nvme" || die "Windows NVMe $nvme does not have an isolated IOMMU group"
        for device in "$vf" "$nvme"; do
          group=$(iommu_group "$device")
          test -r "/dev/vfio/$group" && test -w "/dev/vfio/$group" ||
            die "VFIO group $group for $device is not accessible to $(id -un)"
        done

        ${lib.optionalString (cfg.displayMode == "gtk") ''
          test -n "''${WAYLAND_DISPLAY:-}" || die "WAYLAND_DISPLAY is unset; start from the Niri session"
          test -n "''${XDG_RUNTIME_DIR:-}" || die "XDG_RUNTIME_DIR is unset"
          test -S "''${XDG_RUNTIME_DIR}/''${WAYLAND_DISPLAY}" || die "Wayland socket is unavailable"
        ''}
      }
      wait_for_socket() {
        local socket=$1 label=$2 tries=50
        while test "$tries" -gt 0; do
          test -S "$socket" && return 0
          sleep 0.1
          tries=$((tries - 1))
        done
        die "$label socket did not appear: $socket"
      }
      calculate_emulator_cpus() {
        local configured='${concatStringsSep "," (map toString cfg.emulatorCPUs)}' cpu result=""
        if test -n "$configured"; then printf '%s\n' "$configured"; return; fi
        while read -r cpu; do
          if [[ ",${vcpuList}," != *",$cpu,"* ]]; then
            result="''${result:+$result,}$cpu"
          fi
        done < <(lscpu -p=CPU | grep -v '^#')
        test -n "$result" || die "no host CPUs remain for emulator and I/O threads"
        printf '%s\n' "$result"
      }
      pin_threads() {
        local pid=$1 emulator_cpus=$2 tries=50 task tid name index cpu
        while test "$tries" -gt 0; do
          taskset -pc "$emulator_cpus" "$pid" >/dev/null
          found=0
          for task in /proc/"$pid"/task/*; do
            tid=''${task##*/}
            name=$(cat "$task/comm")
            if [[ "$name" =~ ^CPU[[:space:]]+([0-9]+)/KVM$ ]]; then
              index=''${BASH_REMATCH[1]}
              cpu=$(printf '%s\n' '${concatStringsSep "\n" (map toString cfg.vcpuCPUs)}' | sed -n "$((index + 1))p")
              test -n "$cpu" && taskset -pc "$cpu" "$tid" >/dev/null
              found=$((found + 1))
            else
              taskset -pc "$emulator_cpus" "$tid" >/dev/null 2>&1 || true
            fi
          done
          test "$found" -eq ${toString (builtins.length cfg.vcpuCPUs)} && return 0
          sleep 0.1
          tries=$((tries - 1))
        done
        die "QEMU started but its vCPU threads could not all be pinned"
      }
      cleanup_after_exit() {
        stop_helpers
        rm -f "$qemu_pid" "$qmp_sock" "$qga_sock" "$passt_pid" "$swtpm_pid"
      }
      abort_start() {
        if test -n "''${launched_pid:-}" && kill -0 "$launched_pid" 2>/dev/null; then
          kill "$launched_pid" 2>/dev/null || true
        fi
        stop_helpers
        rm -f "$qemu_pid" "$qmp_sock" "$qga_sock" "$passt_pid" "$swtpm_pid"
      }
      start_vm() {
        local bootstrap=$1 fullscreen=$2 vf emulator_cpus qemu_status
        preflight
        alive "$qemu_pid" && die "the Windows VM is already running (PID $(cat "$qemu_pid"))"

        exec 9>"$state/instance.lock"
        flock -n 9 || die "another process owns the VM state directory"
        launched_pid=""
        trap abort_start EXIT
        rm -f "$qmp_sock" "$qga_sock" "$passt_sock" "$swtpm_sock" "$qemu_pid" "$passt_pid" "$swtpm_pid"
        vf=$(cat "$vf_file")
        emulator_cpus=$(calculate_emulator_cpus)

        mkdir -p "$state/tpm"
        if test ! -f "$state/OVMF_VARS.fd"; then
          install -m 0600 ${pkgs.OVMFFull.fd}/FV/OVMF_VARS.fd "$state/OVMF_VARS.fd"
        fi

        swtpm socket --tpm2 --tpmstate dir="$state/tpm" \
          --ctrl type=unixio,path="$swtpm_sock" --pid file="$swtpm_pid" \
          --terminate --daemon
        wait_for_socket "$swtpm_sock" swtpm

        net_args=()
        ${lib.optionalString (cfg.networkMode == "passt") ''
          passt --socket "$passt_sock" --pid "$passt_pid"
          wait_for_socket "$passt_sock" passt
          net_args=(
            -netdev "stream,id=net0,server=off,addr.type=unix,addr.path=$passt_sock"
            -device "virtio-net-pci,netdev=net0,mac=${cfg.macAddress}"
          )
        ''}

        display_args=(${
          if cfg.displayMode == "gtk" then
            ''-display "gtk,gl=on,full-screen=$fullscreen"''
          else
            "-display egl-headless"
        })
        input_args=()
        ${lib.optionalString cfg.enableInput ''
          input_args=(-device usb-kbd -device usb-tablet)
        ''}
        bootstrap_args=()
        if test "$bootstrap" = yes; then
          bootstrap_args=(
            -drive "file=${pkgs.virtio-win}/share/virtio-win/virtio-win.iso,media=cdrom,if=none,id=virtio-cd"
            -device "scsi-cd,drive=virtio-cd"
          )
        fi

        qemu-system-x86_64 \
          -name windows-11-sriov,debug-threads=on \
          -nodefaults -no-user-config -enable-kvm \
          -machine q35,kernel_irqchip=on,memory-backend=vm-memory \
          -cpu host,hv_relaxed=on,hv_vapic=on,hv_spinlocks=0x1fff,hv_time=on,hv_runtime=on,hv_synic=on,hv_stimer=on,hv_vpindex=on,hv_tlbflush=on,hv_ipi=on,kvm=off \
          -smp ${toString (builtins.length cfg.vcpuCPUs)},sockets=1,cores=${toString (builtins.length cfg.vcpuCPUs)},threads=1 \
          -object memory-backend-memfd,id=vm-memory,size=${toString cfg.memoryMiB}M,share=on,prealloc=on \
          -object iothread,id=iothread0 \
          -overcommit mem-lock=off \
          -drive if=pflash,format=raw,unit=0,readonly=on,file=${pkgs.OVMFFull.fd}/FV/OVMF_CODE.fd \
          -drive if=pflash,format=raw,unit=1,file="$state/OVMF_VARS.fd" \
          -device pcie-root-port,id=rp-gpu,chassis=1,slot=1 \
          -device "vfio-pci,host=$vf,bus=rp-gpu" \
          -device pcie-root-port,id=rp-nvme,chassis=2,slot=2 \
          -device "vfio-pci,host=$nvme,bus=rp-nvme" \
          -device virtio-vga,max_outputs=1,blob=true \
          "''${display_args[@]}" \
          -device qemu-xhci,id=xhci \
          "''${input_args[@]}" \
          -device virtio-scsi-pci,id=scsi0,iothread=iothread0 \
          "''${bootstrap_args[@]}" \
          "''${net_args[@]}" \
          -device virtio-rng-pci \
          -audiodev pipewire,id=audio0 \
          -device intel-hda -device hda-duplex,audiodev=audio0 \
          -device virtio-serial-pci,id=virtio-serial0 \
          -chardev "socket,id=qga,path=$qga_sock,server=on,wait=off" \
          -device virtserialport,chardev=qga,name=org.qemu.guest_agent.0 \
          -chardev "file,id=serial,path=$state/serial.log,append=on" \
          -device isa-serial,chardev=serial \
          -chardev "socket,id=chrtpm,path=$swtpm_sock" \
          -tpmdev emulator,id=tpm0,chardev=chrtpm \
          -device tpm-tis,tpmdev=tpm0 \
          -qmp "unix:$qmp_sock,server=on,wait=off" \
          -pidfile "$qemu_pid" \
          -rtc base=localtime,clock=host,driftfix=slew \
          &
        launched_pid=$!
        trap 'kill "$launched_pid" 2>/dev/null || true; stop_helpers' INT TERM
        wait_for_socket "$qmp_sock" QMP
        pin_threads "$launched_pid" "$emulator_cpus"
        echo "Windows VM running as PID $launched_pid; vCPUs ${vcpuList}; emulator/I/O $emulator_cpus"
        set +e
        wait "$launched_pid"
        qemu_status=$?
        set -e
        trap - INT TERM
        cleanup_after_exit
        trap - EXIT
        return "$qemu_status"
      }
      stop_vm() {
        alive "$qemu_pid" || die "the Windows VM is not running"
        pid=$(cat "$qemu_pid")
        echo "Requesting a clean Windows shutdown..."
        if test -S "$qga_sock"; then
          printf '%s\n' '{"execute":"guest-shutdown","arguments":{"mode":"powerdown"}}' |
            socat -t 2 - UNIX-CONNECT:"$qga_sock" >/dev/null 2>&1 || true
        fi
        sleep 2
        if kill -0 "$pid" 2>/dev/null && test -S "$qmp_sock"; then
          qmp '{"execute":"system_powerdown"}' >/dev/null 2>&1 || true
        fi
        for _ in $(seq 1 90); do
          kill -0 "$pid" 2>/dev/null || { echo "Windows VM stopped cleanly"; return; }
          sleep 1
        done
        die "guest did not shut down within 90 seconds; inspect it or run: windows-vm force-stop"
      }
      force_stop() {
        alive "$qemu_pid" || die "the Windows VM is not running"
        pid=$(cat "$qemu_pid")
        echo "Forcing the Windows VM to stop; guest data may be lost" >&2
        kill -TERM "$pid"
        for _ in $(seq 1 10); do kill -0 "$pid" 2>/dev/null || return; sleep 1; done
        kill -KILL "$pid"
      }
      status_vm() {
        if alive "$qemu_pid"; then echo "process: running (PID $(cat "$qemu_pid"))"; else echo "process: stopped"; fi
        echo "PF: $pf driver=$(driver "$pf" || echo missing) sriov_numvfs=$(cat "/sys/bus/pci/devices/$pf/sriov_numvfs" 2>/dev/null || echo missing)"
        vf=$(cat "$vf_file" 2>/dev/null || true)
        echo "VF: ''${vf:-missing} driver=$(test -n "$vf" && driver "$vf" || echo missing)"
        echo "NVMe: $nvme driver=$(driver "$nvme" || echo missing)"
        echo "TPM: $(alive "$swtpm_pid" && echo running || echo stopped), state=$state/tpm"
        echo "network: ${cfg.networkMode} ($(alive "$passt_pid" && echo running || echo stopped))"
        if test -S "$qmp_sock"; then
          echo -n "QMP: "
          qmp '{"execute":"query-status"}' 2>/dev/null | tail -n 1 || echo unavailable
        else
          echo "QMP: unavailable"
        fi
      }

      command=''${1:-}
      case "$command" in
        start) start_vm no off ;;
        bootstrap) start_vm yes off ;;
        fullscreen) start_vm no on ;;
        stop) stop_vm ;;
        status) status_vm ;;
        force-stop) force_stop ;;
        *)
          echo "Usage: windows-vm {start|bootstrap|fullscreen|stop|status|force-stop}" >&2
          exit 2
          ;;
      esac
    '';
  };
in
{
  options.services.windows-sriov-vm = {
    enable = mkEnableOption "manually launched Windows VM with Intel GPU SR-IOV";
    owner = mkOption {
      type = types.str;
      description = "Unprivileged VM owner.";
    };
    gpuPFAddress = mkOption {
      type = types.str;
      default = "0000:00:02.0";
    };
    windowsNVMeAddress = mkOption { type = types.str; };
    windowsNVMeId = mkOption {
      type = types.str;
      description = "Lower-case vendor:device ID bound early to vfio-pci.";
    };
    memoryMiB = mkOption {
      type = types.ints.positive;
      default = 12288;
    };
    vcpuCPUs = mkOption {
      type = types.listOf types.ints.unsigned;
      default = [
        0
        1
        2
        3
        4
        5
      ];
    };
    emulatorCPUs = mkOption {
      type = types.listOf types.ints.unsigned;
      default = [ ];
      description = "Empty derives all online CPUs not assigned as vCPUs.";
    };
    displayMode = mkOption {
      type = types.enum [
        "gtk"
        "egl-headless"
      ];
      default = "gtk";
    };
    networkMode = mkOption {
      type = types.enum [
        "passt"
        "none"
      ];
      default = "passt";
    };
    macAddress = mkOption {
      type = types.str;
      default = "52:54:00:50:4e:54";
    };
    enableInput = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          builtins.length cfg.vcpuCPUs > 0
          && builtins.length cfg.vcpuCPUs == builtins.length (lib.unique cfg.vcpuCPUs);
        message = "services.windows-sriov-vm.vcpuCPUs must be non-empty and unique";
      }
      {
        assertion = builtins.match "[0-9a-f]{4}:[0-9a-f]{2}:[0-9a-f]{2}\\.[0-7]" cfg.gpuPFAddress != null;
        message = "services.windows-sriov-vm.gpuPFAddress must be a full PCI address";
      }
      {
        assertion =
          builtins.match "[0-9a-f]{4}:[0-9a-f]{2}:[0-9a-f]{2}\\.[0-7]" cfg.windowsNVMeAddress != null;
        message = "services.windows-sriov-vm.windowsNVMeAddress must be a full PCI address";
      }
      {
        assertion = builtins.match "[0-9a-f]{4}:[0-9a-f]{4}" cfg.windowsNVMeId != null;
        message = "services.windows-sriov-vm.windowsNVMeId must be vendor:device";
      }
    ];

    boot.kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      "vfio-pci.ids=${cfg.windowsNVMeId}"
    ];
    boot.initrd.kernelModules = [
      "vfio"
      "vfio_iommu_type1"
      "vfio_pci"
    ];
    boot.kernelModules = [ "vfio-pci" ];

    users.groups.windows-vm = { };
    users.users.${cfg.owner}.extraGroups = [
      "kvm"
      "render"
      "video"
      "windows-vm"
    ];

    environment.systemPackages = [
      windowsVm
      gfxSriovToolkit
      pkgs.OVMFFull
      pkgs.passt
      pkgs.pciutils
      pkgs.qemu_kvm
      pkgs.swtpm
      pkgs.virtio-win
    ];

    system.build.windowsVm = windowsVm;
    system.build.intelGfxSriovToolkit = gfxSriovToolkit;
    system.build.windowsSriovVfProvision = vfProvision;

    systemd.tmpfiles.rules = [
      "d ${stateDir} 0700 ${cfg.owner} windows-vm -"
      "d ${stateDir}/tpm 0700 ${cfg.owner} windows-vm -"
      "d ${runtimeDir} 0750 root windows-vm -"
    ];

    systemd.services.windows-sriov-vf = {
      description = "Provision one Intel GPU SR-IOV VF for the Windows VM";
      wantedBy = [ "multi-user.target" ];
      after = [
        "systemd-modules-load.service"
        "sys-kernel-debug.mount"
      ];
      wants = [ "sys-kernel-debug.mount" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = lib.getExe vfProvision;
      };
    };

    services.udev.extraRules = ''
      # The PF render node remains available to the host desktop.
      SUBSYSTEM=="drm", KERNEL=="renderD*", KERNELS=="${cfg.gpuPFAddress}", GROUP="render", MODE="0660", TAG+="uaccess"
    '';
  };
}
