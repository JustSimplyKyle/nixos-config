{
  config,
  host,
  lib,
  ...
}:
let
  variables = import ../../hosts/${host}/variables.nix;
  wallpaperEngine = variables.wallpaperEngine or [ ];

  # Synced between machines by Syncthing (see modules/core/syncthing.nix)
  # Copy these once from a machine with Wallpaper Engine installed through Steam:
  #   assets/     <- steamapps/common/wallpaper_engine/assets
  #   wallpapers/ <- steamapps/workshop/content/431960/<workshop id>
  dir = "${config.home.homeDirectory}/.local/share/wallpaperengine";

  # Workshop IDs resolve to a folder in the synced dir, absolute paths are used as-is
  resolve = wallpaper: if lib.hasPrefix "/" wallpaper then wallpaper else "${dir}/wallpapers/${wallpaper}";
in
lib.mkIf (wallpaperEngine != [ ]) {
  services.linux-wallpaperengine = {
    enable = true;
    assetsPath = "${dir}/assets";
    audio.silent = true;
    # Keep every monitor animating when a window is fullscreen on another one
    extraOptions = [ "--no-fullscreen-pause" ];
    wallpapers = map (w: w // { wallpaper = resolve w.wallpaper; }) wallpaperEngine;
  };
}
