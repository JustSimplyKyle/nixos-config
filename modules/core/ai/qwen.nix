{ pkgs, ... }:

let
  llamaCppVulkan = pkgs.llama-cpp.override { vulkanSupport = true; };
  defaultModel = "ggml-org/Qwen3.8-27B-GGUF:Q4_K_M";

  qwenChat = pkgs.writeShellApplication {
    name = "qwen-chat";
    text = ''
      exec ${llamaCppVulkan}/bin/llama-cli \
        -hf "''${QWEN_MODEL:-${defaultModel}}" \
        -ngl 99 \
        -c "''${QWEN_CONTEXT:-8192}" \
        --flash-attn on \
        --cache-type-k q8_0 \
        --cache-type-v q8_0 \
        "$@"
    '';
  };

  qwenServe = pkgs.writeShellApplication {
    name = "qwen-serve";
    text = ''
      exec ${llamaCppVulkan}/bin/llama-server \
        -hf "''${QWEN_MODEL:-${defaultModel}}" \
        -ngl 99 \
        -c "''${QWEN_CONTEXT:-16384}" \
        --alias qwen3.8 \
        --flash-attn on \
        --chat-template-file ${./qwen-codex.jinja} \
        --cache-type-k q8_0 \
        --cache-type-v q8_0 \
        --host 127.0.0.1 \
        --port "''${QWEN_PORT:-8001}" \
        "$@"
    '';
  };

in
{
  environment.systemPackages = [
    llamaCppVulkan
    qwenChat
    qwenServe
  ];
}
