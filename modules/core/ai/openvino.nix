{
  pkgs,
  username,
  ...
}:

let
  openvinoPython = pkgs.python3.withPackages (pythonPackages: [
    pythonPackages.huggingface-hub
    pythonPackages.openvino-genai
  ]);
  npuLibraryPath = pkgs.lib.makeLibraryPath [
    pkgs.intel-npu-driver
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
