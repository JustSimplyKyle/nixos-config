{
  config,
  pkgs,
  lib,
  ...
}:

let
  anime4k = pkgs.fetchFromGitHub {
    owner = "bloc97";
    repo = "Anime4K";
    rev = "v4.0.1";
    hash = "sha256-OQWJWcDpwmnJJ/kc4uEReaO74dYFlxNQwf33E5Oagb0=";
  };

  # Recursively search for a filename under a directory, returns the full path
  findGlsl =
    dir: name:
    lib.findFirst (file: builtins.baseNameOf file == name) null (lib.filesystem.listFilesRecursive dir);

  s = name: findGlsl "${anime4k}/glsl" name;
  shaderSet = names: builtins.concatStringsSep ":" (map s names);

  modeA = shaderSet [
    "Anime4K_Clamp_Highlights.glsl"
    "Anime4K_Restore_CNN_VL.glsl"
    "Anime4K_Upscale_CNN_x2_VL.glsl"
    "Anime4K_AutoDownscalePre_x2.glsl"
    "Anime4K_AutoDownscalePre_x4.glsl"
    "Anime4K_Upscale_CNN_x2_M.glsl"
  ];
  modeB = shaderSet [
    "Anime4K_Clamp_Highlights.glsl"
    "Anime4K_Restore_CNN_Soft_VL.glsl"
    "Anime4K_Upscale_CNN_x2_VL.glsl"
    "Anime4K_AutoDownscalePre_x2.glsl"
    "Anime4K_AutoDownscalePre_x4.glsl"
    "Anime4K_Upscale_CNN_x2_M.glsl"
  ];
  modeC = shaderSet [
    "Anime4K_Clamp_Highlights.glsl"
    "Anime4K_Upscale_Denoise_CNN_x2_VL.glsl"
    "Anime4K_AutoDownscalePre_x2.glsl"
    "Anime4K_AutoDownscalePre_x4.glsl"
    "Anime4K_Upscale_CNN_x2_M.glsl"
  ];
  modeAA = shaderSet [
    "Anime4K_Clamp_Highlights.glsl"
    "Anime4K_Restore_CNN_VL.glsl"
    "Anime4K_Upscale_CNN_x2_VL.glsl"
    "Anime4K_Restore_CNN_M.glsl"
    "Anime4K_AutoDownscalePre_x2.glsl"
    "Anime4K_AutoDownscalePre_x4.glsl"
    "Anime4K_Upscale_CNN_x2_M.glsl"
  ];
  modeBB = shaderSet [
    "Anime4K_Clamp_Highlights.glsl"
    "Anime4K_Restore_CNN_Soft_VL.glsl"
    "Anime4K_Upscale_CNN_x2_VL.glsl"
    "Anime4K_AutoDownscalePre_x2.glsl"
    "Anime4K_AutoDownscalePre_x4.glsl"
    "Anime4K_Restore_CNN_Soft_M.glsl"
    "Anime4K_Upscale_CNN_x2_M.glsl"
  ];
  modeCA = shaderSet [
    "Anime4K_Clamp_Highlights.glsl"
    "Anime4K_Upscale_Denoise_CNN_x2_VL.glsl"
    "Anime4K_AutoDownscalePre_x2.glsl"
    "Anime4K_AutoDownscalePre_x4.glsl"
    "Anime4K_Restore_CNN_M.glsl"
    "Anime4K_Upscale_CNN_x2_M.glsl"
  ];
in
{
  programs.mpv = {
    enable = true;

    bindings = {
      "RIGHT" = "script-binding skip-next-conditional";
      "LEFT" = "script-binding skip-prev-conditional";

      "CTRL+1" = ''no-osd change-list glsl-shaders set "${modeA}";  show-text "Anime4K: Mode A (HQ)"'';
      "CTRL+2" = ''no-osd change-list glsl-shaders set "${modeB}";  show-text "Anime4K: Mode B (HQ)"'';
      "CTRL+3" = ''no-osd change-list glsl-shaders set "${modeC}";  show-text "Anime4K: Mode C (HQ)"'';
      "CTRL+4" = ''no-osd change-list glsl-shaders set "${modeAA}"; show-text "Anime4K: Mode A+A (HQ)"'';
      "CTRL+5" = ''no-osd change-list glsl-shaders set "${modeBB}"; show-text "Anime4K: Mode B+B (HQ)"'';
      "CTRL+6" = ''no-osd change-list glsl-shaders set "${modeCA}"; show-text "Anime4K: Mode C+A (HQ)"'';
      "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
    };

    package = pkgs.mpv.override {
      mpv-unwrapped = pkgs.mpv-unwrapped.override {
        cddaSupport = true;
        waylandSupport = true;
      };
      scripts =
        with pkgs.mpvScripts;
        [
          uosc
          sponsorblock
          thumbfast
          mpris
        ]
        ++ [
          pkgs.mpv-skip-conditional
        ];
    };

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
      ytdl-raw-options = "yes-playlist=,cookies-from-browser=chromium:${config.xdg.configHome}/net.imput.helium/Default";
      hwdec = "auto";
      hwdec-codecs = "all";
      profile = "high-quality";
      vo = "gpu-next";
      video-sync = "display-resample";
      volume = 85;
      blend-subtitles = "video";
      ao = "pipewire";
      sub-font-size = 36;
      cache = "yes";
      save-position-on-quit = "yes";
      osc = "no";
      osd-bar = "no";
      border = "no";
      demuxer-readahead-secs = 120;
      sub-font = "jf open 粉圓 2.1";
    };
  };
}
