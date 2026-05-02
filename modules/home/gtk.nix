{ pkgs, lib, ... }:

{
  qt = {
    enable = true;
    platformTheme.name = "qtct"; # Use qt5ct/qt6ct defined by Stylix
    style = {
      # Force the style to adwaita-dark so you get the "Shapes"
      name = lib.mkForce "adwaita-dark"; 
      package =  lib.mkForce pkgs.adwaita-qt;
    };
  };


  gtk = {
    enable = true;
    theme = {
      name = lib.mkForce "adw-gtk3-dark";
      package = lib.mkForce pkgs.adw-gtk3;
    };
    
    iconTheme = {
      name = "Fluent-dark";
      package = pkgs.fluent-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
