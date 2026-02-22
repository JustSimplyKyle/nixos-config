{ pkgs, lib, ... }:

{
  # qt = {
  #   enable = true;
  #   platformTheme.name = "qtct"; # Use qt5ct/qt6ct defined by Stylix
  #   style = {
  #     # Force the style to adwaita-dark so you get the "Shapes"
  #     name = lib.mkForce "adwaita-dark"; 
  #     package = lib.mkForce pkgs.adwaita-qt;
  #   };
  # };

  gtk = {
    enable = true;
    theme = {
      # Use lib.mkForce to stop Stylix from overriding this back to "Stylix-Dark"
      name = lib.mkForce "adw-gtk3-dark";
      package = lib.mkForce pkgs.adw-gtk3;
    };
    
    iconTheme = {
      name = "Tela-purple-dark";
      package = pkgs.tela-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
