{
  inputs,
  pkgs,
  username,
  ...
}:

let
  openvinoPkgs = import inputs.nixpkgs-openvino {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
  intelNpuCompiler = pkgs.callPackage ../../../pkgs/intel-npu-compiler.nix { };
  # The NPU plugin resolves its compiler relative to its own shared object,
  # rather than through LD_LIBRARY_PATH. Build the expected directory layout
  # without recompiling OpenVINO.
  openvinoNpuRuntime = pkgs.runCommand "openvino-2026.2.1-npu-runtime" { } ''
    mkdir -p "$out"
    cp -a ${openvinoPkgs.openvino.lib}/. "$out/"
    chmod -R u+w "$out"
    cp -a ${intelNpuCompiler}/lib/libopenvino_intel_npu_compiler*.so \
      "$out/lib/openvino/"
  '';
  openvinoPython = openvinoPkgs.python3.withPackages (pythonPackages: [
    pythonPackages.huggingface-hub
    pythonPackages.openvino-genai
  ]);
  npuLibraryPath = pkgs.lib.makeLibraryPath [
    openvinoNpuRuntime
    pkgs.intel-npu-driver
    intelNpuCompiler
    pkgs.level-zero
  ];

  writeOpenvinoApplication =
    {
      name,
      script,
      runtimeInputs ? [ ],
    }:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ openvinoPython ] ++ runtimeInputs;
      text = ''
        export LD_LIBRARY_PATH="${npuLibraryPath}''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}"
        exec python ${script} "$@"
      '';
    };

  qwenNpuChat = writeOpenvinoApplication {
    name = "qwen-npu-chat";
    script = ./qwen-npu-chat.py;
  };

  openvinoSpeechToText = writeOpenvinoApplication {
    name = "openvino-stt";
    script = ./openvino-stt.py;
    runtimeInputs = [ pkgs.ffmpeg ];
  };
in
{
  hardware.cpu.intel.npu.enable = true;
  hardware.graphics.extraPackages = [ intelNpuCompiler ];

  environment.systemPackages = [
    openvinoSpeechToText
    qwenNpuChat
  ];

  # Intel GPU and NPU device nodes are normally owned by these groups.
  users.users.${username}.extraGroups = [
    "render"
    "video"
  ];
}
