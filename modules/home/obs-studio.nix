{ 
  pkgs,
  useNvidia,
  ... 
}:
{
  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      cudaSupport = useNvidia; # Set in host/variables.nix
    };
    #enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-vkcapture
      obs-source-clone
      obs-move-transition
      obs-composite-blur
      obs-backgroundremoval
    ];
  };
}
