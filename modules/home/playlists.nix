{ ... }:

{
  xdg.desktopEntries = {
    "play-mix" = {
      name = ">Play: Youtube Mix";
      genericName = "YouTube Stream";
      exec = ''mpv "https://www.youtube.com/watch?v=zjEMFuj23B4&list=RDzjEMFuj23B4&start_radio=1" --shuffle --no-resume-playback --wayland-app-id="mpv-stream"'';
      icon = "mpv";
      terminal = false;
      categories = [ "AudioVideo" ];
    };

    "play-zutomayo" = {
      name = ">Play: Zutomayo";
      genericName = "YouTube Stream";
      exec = ''mpv "https://www.youtube.com/playlist?list=PLbH4jxOhb1-I_xxosxZRwcDp_V1AOyrl8" --shuffle --no-resume-playback --wayland-app-id="mpv-stream"'';
      icon = "mpv";
      terminal = false;
      categories = [ "AudioVideo" ];
    };
  };
}
