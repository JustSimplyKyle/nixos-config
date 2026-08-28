{ pkgs, ... }:

let
  qwenClientPython = pkgs.python3.withPackages (pythonPackages: [
    pythonPackages.openai
  ]);

  mkQwenServe =
    {
      name,
      defaultModel,
      defaultImage,
      defaultPort,
      ovmsArgs,
    }:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [
        pkgs.coreutils
        pkgs.docker-client
      ];
      text = ''
        model="''${QWEN_MODEL:-${defaultModel}}"
        image="''${QWEN_OVMS_IMAGE:-${defaultImage}}"
        port="''${QWEN_PORT:-${toString defaultPort}}"
        device="''${QWEN_DEVICE:-GPU}"
        model_repository="''${QWEN_MODEL_REPOSITORY:-''${XDG_CACHE_HOME:-$HOME/.cache}/openvino/model-server}"

        mkdir -p "$model_repository"

        docker_args=(
          --rm
          --user "$(id -u):$(id -g)"
          --publish "127.0.0.1:$port:8000"
          --volume "$model_repository:/models:rw"
        )

        if [[ "$device" == "GPU" ]]; then
          shopt -s nullglob
          render_nodes=(/dev/dri/render*)
          if (( ''${#render_nodes[@]} == 0 )); then
            echo "No GPU render node found under /dev/dri" >&2
            exit 1
          fi
          render_group="$(stat -c '%g' "''${render_nodes[0]}")"
          docker_args+=(--device /dev/dri --group-add "$render_group")
        fi

        exec docker run "''${docker_args[@]}" "$image" \
          --rest_port 8000 \
          --source_model "$model" \
          --model_repository_path /models \
          --cache_dir /models/.cache \
          --target_device "$device" \
          --task text_generation \
          ${pkgs.lib.escapeShellArgs ovmsArgs} \
          "$@"
      '';
    };

  qwenServe = mkQwenServe {
    name = "qwen-serve";
    defaultModel = "OpenVINO/Qwen3.6-35B-A3B-int4-ov";
    defaultImage = "openvino/model_server:latest-gpu";
    defaultPort = 8001;
    ovmsArgs = [
      "--reasoning_parser"
      "qwen3"
      "--tool_parser"
      "qwen3coder"
      "--allowed_media_domains"
      "raw.githubusercontent.com"
    ];
  };

  qwen38Serve = mkQwenServe {
    name = "qwen3.8-serve-experimental";
    defaultModel = "OpenVINO/Qwen3.8-27B-int4-ov";
    # Qwen 3.8 needs OpenVINO 2026.4 nightly until it is in a stable release.
    defaultImage = "openvino/model_server:weekly";
    defaultPort = 8003;
    ovmsArgs = [
      "--allowed_media_domains"
      "all"
    ];
  };

  qwenChat = pkgs.writeShellApplication {
    name = "qwen-chat";
    runtimeInputs = [ qwenClientPython ];
    text = ''
      exec python ${./qwen-openai-chat.py} "$@"
    '';
  };

  qwenCodexProxy = pkgs.writeShellApplication {
    name = "qwen-codex-proxy";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      exec python ${./qwen-codex-proxy.py} "$@"
    '';
  };
in
{
  environment.systemPackages = [
    qwenChat
    qwenCodexProxy
    qwenServe
    qwen38Serve
  ];
}
