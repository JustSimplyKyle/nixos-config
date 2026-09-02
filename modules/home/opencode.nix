{ pkgs, ... }:

let
  qwenModel = "OpenVINO/Qwen3.8-27B-int4-ov";
in
{
  xdg.configFile."opencode/opencode.json".source = (pkgs.formats.json { }).generate "opencode.json" {
    "$schema" = "https://opencode.ai/config.json";

    provider.qwen-openvino = {
      npm = "@ai-sdk/openai-compatible";
      name = "Qwen 3.8 OpenVINO (local)";
      options.baseURL = "http://127.0.0.1:8003/v3";
      models.${qwenModel} = {
        name = "Qwen 3.8 27B OpenVINO";
        limit = {
          context = 32768;
          output = 16384;
        };
      };
    };

    # Select this from OpenCode's agent picker to use the local qwen-serve model.
    agent.qwen = {
      description = "Coding profile using the local Qwen OpenVINO server";
      mode = "primary";
      model = "qwen-openvino/${qwenModel}";
    };
  };
}
