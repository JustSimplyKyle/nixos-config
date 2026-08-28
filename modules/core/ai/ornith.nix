{ pkgs, ... }:

let
  llamaCppVulkan = pkgs.llama-cpp.override { vulkanSupport = true; };
  defaultRepo = "mudler/Ornith-1.5-35B-A3B-APEX-MTP-GGUF";
  defaultFile = "Ornith-1.5-35B-A3B-APEX-MTP-Compact.gguf";

  ornithChat = pkgs.writeShellApplication {
    name = "ornith-chat";
    text = ''
      exec ${llamaCppVulkan}/bin/llama-cli \
        -hf "''${ORNITH_REPO:-${defaultRepo}}" \
        -hff "''${ORNITH_FILE:-${defaultFile}}" \
        -ngl 99 \
        -c "''${ORNITH_CONTEXT:-8192}" \
        --flash-attn on \
        --cache-type-k q8_0 \
        --cache-type-v q8_0 \
        --spec-type draft-mtp \
        --spec-draft-n-max 2 \
        "$@"
    '';
  };

  ornithServe = pkgs.writeShellApplication {
    name = "ornith-serve";
    text = ''
      exec ${llamaCppVulkan}/bin/llama-server \
        -hf "''${ORNITH_REPO:-${defaultRepo}}" \
        -hff "''${ORNITH_FILE:-${defaultFile}}" \
        -ngl 99 \
        -c "''${ORNITH_CONTEXT:-131072}" \
        --alias ornith-1.5 \
        --chat-template-file ${./qwen-codex.jinja} \
        --flash-attn on \
        --cache-type-k q8_0 \
        --cache-type-v q8_0 \
        --spec-type draft-mtp \
        --spec-draft-n-max 2 \
        --host 127.0.0.1 \
        --port "''${ORNITH_PORT:-8002}" \
        "$@"
    '';
  };
in
{
  environment.systemPackages = [
    ornithChat
    ornithServe
  ];
}
