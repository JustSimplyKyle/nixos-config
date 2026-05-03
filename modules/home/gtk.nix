{ pkgs, lib, ... }:
let
  fluent = pkgs.fluent-gtk-theme.override {
    tweaks = [ "blur" "round" ];
    colorVariants = [ "dark" ];
  };
  whitesur = pkgs.whitesur-gtk-theme.override {
    colorVariants    = [ "dark" ];
    opacityVariants  = [ "normal" ];   # not "solid" — keeps transparency
    nautilusStyle    = "glassy";       # the frosted glass nautilus variant
    schemeVariants   = [ "standard" ];
    themeVariants    = [ "default" ];
    panelOpacity     = "30";           # lowest available = most transparent panel
    darkerColor      = true;           # deeper dark base, better contrast through glass
    roundedMaxWindow = true;
  };
  glassy-originals-gtk-black-dark = pkgs.stdenv.mkDerivation {
    pname = "glassy-originals-gtk-black-dark";
    version = "unstable";

    src = pkgs.fetchzip {
      url    = "https://files.simplykyle.eu.org/u/Glassy-Originals-Gtk-Black-Dark.zip";  # <-- fill this in
      hash   = "sha256-k/VJ+r2Ofk9TjG66Yb5HCMSSdk0uNYz5B4ibH5pYsd4=";  # <-- run once with fake hash to get real one
    };

    dontBuild = true;
    sourceRoot = "source/Glassy-Originals-Gtk-Black-Dark";

    installPhase = ''
      mkdir -p $out/share/themes/Glassy-Originals-Gtk-Black-Dark
      ls
      cp -r gtk-4.0   $out/share/themes/Glassy-Originals-Gtk-Black-Dark/
      cp -r gtk-3.0   $out/share/themes/Glassy-Originals-Gtk-Black-Dark/
      cp    index.theme $out/share/themes/Glassy-Originals-Gtk-Black-Dark/
    '';
  };
  in
{
  qt = {
    enable = true;
    platformTheme.name = "qtct"; # Use qt5ct/qt6ct defined by Stylix
    style = {
      name = "adwaita-dark"; 
      package = pkgs.adwaita-qt;
    };
  };

  home.packages = [ pkgs.instrument-sans ];

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  gtk = {
    enable = true;
    theme = {
      name = "WhiteSur-Dark";
      package = whitesur;
    };
    # theme = {
    #   name = "Fluent-round-Dark";
    #   package = fluent;
    # };
    # theme = {
    #   name = "Glassy-Originals-Gtk-Black-Dark";
    #   package = glassy-originals-gtk-black-dark;
    # };

    gtk4.extraCss = ''
      :root {
          /* ── Sidebar: heavy frosted glass ─────────────────────────── */
          --sidebar-bg-color:          rgba(14, 14, 18, 0.70);
          --sidebar-backdrop-color:    rgba(14, 14, 18, 0.70);  /* unfocused */
          /* ── File view: darker base so light BGs don't bleed through ─ */
          --view-bg-color:             rgba(14, 14, 18, 0.55);
          /* ── Window base ─────────────────────────────────────────── */
          --window-bg-color:           rgba(14, 14, 18, 0.60);
          /* ── Header bar ──────────────────────────────────────────── */
          --headerbar-bg-color:        rgba(14, 14, 18, 0.72);
          --headerbar-backdrop-color:  rgba(14, 14, 18, 0.72);  /* unfocused */
          /* ── Popovers/menus ──────────────────────────────────────── */
          --popover-bg-color:          rgba(22, 22, 28, 0.68);
          /* ── Cards (selected/hover states) ──────────────────────── */
          --card-bg-color:             rgba(255, 255, 255, 0.05);
      }
      /* Subtle glass edge between sidebar and content */
      .sidebar {
          border-right: 1px solid rgba(255, 255, 255, 0.06);
      }
      /* Keep popovers readable */
      popover > contents {
          background-color: var(--popover-bg-color);
      }
  '';
    gtk3.extraCss = ''

      @define-color window_bg_color      rgba(14, 14, 18, 0.60);
      @define-color view_bg_color        rgba(14, 14, 18, 0.55);
      @define-color headerbar_bg_color   rgba(14, 14, 18, 0.72);
      @define-color sidebar_bg_color     rgba(14, 14, 18, 0.70);
      @define-color popover_bg_color     rgba(22, 22, 28, 0.68);
      @define-color card_bg_color        rgba(255, 255, 255, 0.05);


      /* GTK3 also needs direct selectors — @define-color alone isn't enough */
      window, .background {
          background-color: @window_bg_color;
      }
      headerbar, .titlebar {
          background-color: @headerbar_bg_color;
      }
      .sidebar {
          background-color: @sidebar_bg_color;
          border-right: 1px solid rgba(255, 255, 255, 0.06);
      }
      .view, treeview, iconview {
          background-color: @view_bg_color;
      }
      popover, .popover {
          background-color: @popover_bg_color;
      }
      menu {
          background-color: @popover_bg_color;
          color: white;
      }

      menuitem {
          background-color: transparent;
      }

      menuitem:hover {
          background-color: rgba(255, 255, 255, 0.07);
      }

      menuitem separator {
          background-color: rgba(255, 255, 255, 0.06);
          min-height: 1px;
      }

      menu > arrow {
          background-color: @popover_bg_color;
      }

      paned {
          background-color: @window_bg_color;
      }

      scrolledwindow {
          background-color: @view_bg_color;
      }

      viewport {
          background-color: @view_bg_color;
      }
    '';

    # iconTheme = {
    #   name = "Fluent-dark";
    #   package = pkgs.fluent-icon-theme;
    # };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;

    };
  };
}
