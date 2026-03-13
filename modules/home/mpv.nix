{ pkgs, ...}: {
  programs.mpv = {
    enable = true;

    # Map your preferred key here (e.g., "n")
    bindings = {
      "RIGHT" = "script-binding skip-next-conditional";
      "LEFT" = "script-binding skip-prev-conditional";
    };

    scripts = with pkgs.mpvScripts;[
      uosc
      sponsorblock
    ] ++ [
      pkgs.mpv-skip-conditional 
    ];

    scriptOpts = {
      uosc = {
        font_scale = 2; 
      };
    };

    config = {
      ytdl-format = "bestvideo[height<=?1440]+bestaudio/best";
      ytdl-raw-options = "yes-playlist=";
      hwdec = "auto";
      hwdec-codecs = "all";
      profile = "high-quality";
      vo = "gpu-next";
      volume = 85;
      blend-subtitles = "video";
      ao = "pipewire";
      sub-font-size = 44;
      cache = "yes";
      save-position-on-quit = "yes";
      
      demuxer-readahead-secs = 120;
    };
  };
}
