{ host, ... }:
let
  inherit (import ../../../hosts/${host}/variables.nix)
    browser
    terminal
    barChoice
    ;

  # Import host-specific binds
  hostBinds = import ./hosts/${host}/binds.nix { inherit host; };

  # Determine launcher command based on barChoice
  launcherCommand =
    if barChoice == "noctalia" then
      "noctalia-shell ipc call launcher toggle"
    else if barChoice == "dms" then
      "dms ipc call spotlight toggle"
    else
      "rofi-launcher";

  # Noctalia-specific keybinds
  noctaliaBinds =
    if barChoice == "noctalia" then
      [
        "$modifier,comma,exec,noctalia-shell ipc call settings toggle"
        "$modifier ALT,S,exec,noctalia-shell ipc call settings toggle"
        "$modifier SHIFT,C,exec,noctalia-shell ipc call controlCenter toggle"
      ]
    else
      [ ];

  # DMS-specific keybinds
  dmsBinds =
    if barChoice == "dms" then
      [
        "$modifier,comma,exec,ignis open-window Settings"
        "$modifier SHIFT,V,exec,dms ipc call clipboard toggle"
        "$modifier,M,exec,dms ipc call processlist toggle"
        "$modifier ALT,S,exec,dms ipc call settings toggle"
        "$modifier,N,exec,dms ipc call notifications toggle"
        "$modifier SHIFT,N,exec,dms ipc call notepad toggle"
        "$modifier ALT,L,exec,dms ipc call lock lock"
        "CTRL ALT,Delete,exec,dms ipc call processlist toggle"
        ",XF86AudioRaiseVolume,exec,dms ipc call audio increment 3"
        ",XF86AudioLowerVolume,exec,dms ipc call audio decrement 3"
        ",XF86AudioMute,exec,dms ipc call audio mute"
        ",XF86AudioMicMute,exec,dms ipc call audio micmute"
        ",XF86MonBrightnessDown,exec,dms ipc call brightness decrement 5 ''"
        ",XF86MonBrightnessUp,exec,dms ipc call brightness increment 5 ''"
      ]
    else
      [ ];

  # Default binds that all hosts inherit
  defaultBinds = [
    "$modifier,T,exec,${terminal}"
    "$modifier SHIFT CTRL,D,exec,nwg-displays"
    "$modifier ALT,M,exec,appimage-run ./Moonlight-6.1.0-x86_64.AppImage"
    "$modifier,K,exec,list-keybinds"
    "$modifier,Z,exec,pypr zoom"
    "$modifier,SPACE,exec,${launcherCommand}"
    "$modifier SHIFT,W,exec,web-search"
    "$modifier ALT,W,exec,wallsetter"
    "$modifier,B,exec,${browser}"
    "$modifier,Y,exec,kitty -e yazi"
    "$modifier CTRL,E,exec,emopicker9000"
    "$modifier SHIFT,S,exec,screenshootin"
    "$modifier,D,exec,vesktop"
    "$modifier SHIFT,V,exec,virt-manager"
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
    "$modifier,R,layoutmsg,colresize +conf"
    "$modifier SHIFT,R,layoutmsg,colresize -conf"
    "$modifier CTRL,R,layoutmsg,colresize 0.5"
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
    "$modifier SHIFT,left,layoutmsg,swapcol l"
    "$modifier SHIFT,right,layoutmsg,swapcol r"
    "$modifier SHIFT,up,swapwindow,u"
    "$modifier SHIFT,down,swapwindow,d"
    "$modifier SHIFT,h,movewindow,l"
    "$modifier SHIFT,l,movewindow,r"
    "$modifier SHIFT,k,movewindow,u"
    "$modifier SHIFT,j,movewindow,d"
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
    "$modifier CTRL,mouse_down,workspace, r+1"
    "$modifier CTRL,mouse_up,workspace, r-1"
    "ALT,Tab,cyclenext"
    "ALT,Tab,bringactivetotop"
    ",XF86AudioPlay, exec, playerctl play-pause"
    ",XF86AudioPause, exec, playerctl play-pause"
    ",XF86AudioNext, exec, playerctl next"
    ",XF86AudioPrev, exec, playerctl previous"
  ]
  # Audio and brightness binds (only when DMS is not active)
  ++ (
    if barChoice != "dms" then
      [
        ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        " ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86MonBrightnessDown,exec,brightnessctl set 5%-"
        ",XF86MonBrightnessUp,exec,brightnessctl set +5%"
      ]
    else
      [ ]
  );

  # Default mouse binds
  defaultBindm = [
    "$modifier, mouse:272, movewindow"
    "$modifier, mouse:273, resizewindow"
  ];

in
{
  wayland.windowManager.hyprland.settings = {
    # Merge default binds with host-specific binds and conditional shell binds
    bind = defaultBinds ++ noctaliaBinds ++ dmsBinds ++ hostBinds.bind;
    bindm = defaultBindm ++ hostBinds.bindm;
  };
}
