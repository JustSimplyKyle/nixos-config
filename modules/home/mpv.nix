{ config, pkgs, ...}: {
  programs.mpv = {
    enable = true;

    # Map your preferred key here (e.g., "n")
    bindings = {
      "RIGHT" = "script-binding skip-next-conditional";
      "LEFT" = "script-binding skip-prev-conditional";
    };

    scripts = with pkgs.mpvScripts; [
      uosc
      sponsorblock
      thumbfast
      mpris
    ] ++ [
      pkgs.mpv-skip-conditional 
    ];

    scriptOpts = {
      uosc = {
        font_scale = 2; 
      };

      thumbfast = {
        network = true;
        hwdec = true; 
      };
    };

    config = {
      ytdl-format = "bestvideo[height<=?1440]+bestaudio/best";
      ytdl-raw-options =  "yes-playlist=,cookies-from-browser=chromium:${config.xdg.configHome}/net.imput.helium/Default";
      hwdec = "auto";
      hwdec-codecs = "all";
      profile = "high-quality";
      vo = "gpu-next";
      video-sync="display-resample";
      volume = 85;
      blend-subtitles = "video";
      ao = "pipewire";
      sub-font-size = 44;
      cache = "yes";
      save-position-on-quit = "yes";

      osc = "no";
      osd-bar = "no";
      border = "no";
      
      demuxer-readahead-secs = 120;
    };
  };
}
