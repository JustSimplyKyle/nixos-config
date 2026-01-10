{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) amdID nvidiaID;
in
{
  imports = [
    ../../hosts/${host}
    ../../modules/drivers
    ../../modules/core
  ];
  # Enable GPU Drivers
  drivers.amdgpu.enable = false;

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "${amdID}";
      nvidiaBusId = "${nvidiaID}";
    };
  };
  # drivers.nvidia-prime = {
  #   enable = true;
  #   amdBusId = "${amdID}";
  # };
  drivers.intel.enable = false;
  vm.guest-services.enable = false;
}
