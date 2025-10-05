{host, ...}: let
  inherit
    (import ../../../hosts/${host}/variables.nix)
    browser
    terminal
    ;

  # Import host-specific binds
  hostBinds = import ./hosts/${host}/binds.nix {inherit host;};

  # Default binds that all hosts inherit
  defaultBinds = [
      "$modifier,T,exec,${terminal}"
      "$modifier SHIFT CTRL,D,exec,nwg-displays"
      "$modifier ALT,M,exec,appimage-run ./Moonlight-6.1.0-x86_64.AppImage"
      "$modifier,K,exec,list-keybinds"
      "$modifier,Z,exec,pypr zoom"
      #"$modifier,SPACE,exec,vicinae"
      "$modifier,SPACE,exec,rofi-launcher"
      "$modifier SHIFT,W,exec,web-search"
      "$modifier ALT,W,exec,wallsetter"
      #"$modifier,B,exec,${browser}"
      "$modifier,Y,exec,kitty -e yazi"
      "$modifier SHIFT,E,exec,emopicker9000"
      "$modifier SHIFT,S,exec,screenshootin"
      "$modifier,D,exec,vesktop"
      "$modifier,S,exec,steam"
      "$modifier SHIFT,O,exec,flatpak run com.obsproject.Studio"
      "$modifier SHIFT,Z,exec,zeditor"
      "$modifier,C,exec,hyprpicker -a"
      "$modifier,L,exec,hyprlock"
      "$modifier,X,exec,wlogout"
      "$modifier,G,exec,telegram-desktop"
      "$modifier SHIFT,T,exec,pypr toggle term"
      "$modifier,M,exec,pavucontrol"
      "$modifier,E,exec,hyprctl dispatch hyprexpo:expo toggle"
      "$modifier,R,exec,~/.config/hypr/scripts/toggle-half-full.sh"
      "$modifier,minus,resizeactive,-10% -10%"
      "$modifier,equal,resizeactive,10% 10%"
      "$modifier SHIFT,minus,resizewindowpixel,-30% -30%"
      "$modifier SHIFT,equal,resizewindowpixel,30% 30%"
      "$modifier,Q,killactive,"
      "$modifier,P,pseudo,"
      "$modifier SHIFT,I,togglesplit,"
      "$modifier SHIFT,F,fullscreen,"
      "$modifier CTRL,F,fullscreen,1"
      "$modifier,F,exec,thunar"
      "$modifier,W,togglefloating,"
      "$modifier SHIFT CTRL,W,workspaceopt, allfloat"
      "$modifier SHIFT,left,swapwindow,l"
      "$modifier SHIFT,right,swapwindow,r"
      "$modifier SHIFT,up,swapwindow,u"
      "$modifier SHIFT,down,swapwindow,d"
      "$modifier SHIFT,h,movewindow,l"
      "$modifier SHIFT,l,movewindow,r"
      "$modifier SHIFT,k,movewindow,u"
      "$modifier SHIFT,j,movewindow,d"
      "$modifier CTRL,left,movecurrentworkspacetomonitor,l"
      "$modifier CTRL,right,movecurrentworkspacetomonitor,r"
      "$modifier ALT, left, swapwindow,l"
      "$modifier ALT, right, swapwindow,r"
      "$modifier ALT, up, swapwindow,u"
      "$modifier ALT, down, swapwindow,d"
      "$modifier ALT, 43, swapwindow,l"
      "$modifier ALT, 46, swapwindow,r"
      "$modifier ALT, 45, swapwindow,u"
      "$modifier ALT, 44, swapwindow,d"
      "$modifier,left,movefocus,l"
      "$modifier,right,movefocus,r"
      "$modifier,up,movefocus,u"
      "$modifier,down,movefocus,d"
      #"$modifier,h,movefocus,l"
      #"$modifier,l,movefocus,r"
      #"$modifier,k,movefocus,u"
      #"$modifier,j,movefocus,d"
      "$modifier,1,workspace,1"
      "$modifier,2,workspace,2"
      "$modifier,3,workspace,3"
      "$modifier,4,workspace,4"
      "$modifier,5,workspace,5"
      "$modifier,6,workspace,6"
      "$modifier,7,workspace,7"
      "$modifier,8,workspace,8"
      "$modifier,9,workspace,9"
      "$modifier,0,workspace,10"
      #"$modifier SHIFT,SPACE,movetoworkspace,special"
      #"$modifier,SPACE,togglespecialworkspace"
      "$modifier SHIFT,1,movetoworkspace,1"
      "$modifier SHIFT,2,movetoworkspace,2"
      "$modifier SHIFT,3,movetoworkspace,3"
      "$modifier SHIFT,4,movetoworkspace,4"
      "$modifier SHIFT,5,movetoworkspace,5"
      "$modifier SHIFT,6,movetoworkspace,6"
      "$modifier SHIFT,7,movetoworkspace,7"
      "$modifier SHIFT,8,movetoworkspace,8"
      "$modifier SHIFT,9,movetoworkspace,9"
      "$modifier SHIFT,0,movetoworkspace,10"
      "$modifier Ctrl Alt,down, movetoworkspace, r+1"
      "$modifier Ctrl Alt,up, movetoworkspace, r-1"
      "$modifier CONTROL,down,workspace,r+1"
      "$modifier CONTROL,up,workspace,r-1"
      "$modifier,mouse_down,workspace, r+1"
      "$modifier,mouse_up,workspace, r-1"
      "ALT,Tab,cyclenext"
      "ALT,Tab,bringactivetotop"
      ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      " ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioPlay, exec, playerctl play-pause"
      ",XF86AudioPause, exec, playerctl play-pause"
      ",XF86AudioNext, exec, playerctl next"
      ",XF86AudioPrev, exec, playerctl previous"
      ",XF86MonBrightnessDown,exec,brightnessctl set 5%-"
      ",XF86MonBrightnessUp,exec,brightnessctl set +5%"
    ];

  # Default mouse binds
  defaultBindm = [
    "$modifier, mouse:272, movewindow"
    "$modifier, mouse:273, resizewindow"
  ];

in {
  wayland.windowManager.hyprland.settings = {
    # Merge default binds with host-specific binds
    bind = defaultBinds ++ hostBinds.bind;
    bindm = defaultBindm ++ hostBinds.bindm;
  };
}
