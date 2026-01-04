{ pkgs, ... }: {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      ignoreUserConfig = true;
      addons = with pkgs; [
        fcitx5-fluent
        (fcitx5-rime.override {
          rimeDataPkgs = [
            # Wrap local files so they end up in the 'share/rime-data' subpath
            (runCommand "chasew-rime-data" {} ''
              mkdir -p $out/share/rime-data
              cp -r ${./chasew}/* $out/share/rime-data/
      '')
            rime-data
          ];
        })
        qt6Packages.fcitx5-chinese-addons
      ];
      settings = {
       # This is the correct path for UI/Theme settings
        addons.classicui.globalSection = {
          Theme = "FluentDark-solid";
          # Use "Sans" followed by the size to change size without hardcoding a font
          Font = "Sans 14";
          MenuFont = "Sans 14";
          TrayFont = "Sans 14";
          # Use "True"/"False" strings because Fcitx5 is case-sensitive with booleans
          VerticalCandidateList = "False";
        };
        globalOptions = {
          "Hotkey" = {
            EnumerateWithTriggerKeys = false;
            ActivateKeys = "";
            DeactivateKeys = "";
            EnumerateSkipFirst = false;
            ModifierOnlyKeyTimeout = 250;
          };

          "Hotkey/TriggerKeys" = {
            "0" = "Control+space";
          };

          "Hotkey/AltTriggerKeys" = {
            "0" = "Control+Shift+Control_L";
          };

          "Hotkey/EnumerateForwardKeys" = {
            "0" = "Control+Shift_L";
          };

          "Hotkey/EnumerateBackwardKeys" = {
            "0" = "Control+Shift_R";
          };

          "Hotkey/EnumerateGroupForwardKeys" = {
            "0" = "Alt+Shift+Shift_L";
          };

          "Hotkey/EnumerateGroupBackwardKeys" = {
            "0" = "Shift+Super+space";
          };

          "Hotkey/PrevPage" = {
            "0" = "Up";
          };

          "Hotkey/NextPage" = {
            "0" = "Down";
          };

          "Hotkey/PrevCandidate" = {
            "0" = "Shift+Tab";
          };

          "Hotkey/NextCandidate" = {
            "0" = "Tab";
          };

          "Hotkey/TogglePreedit" = {
            "0" = "Control+Alt+P";
          };

          "Behavior" = {
            ActiveByDefault = true;
            # "No" is specific to fcitx5 config, usually distinct from False in behavior logic
            resetStateWhenFocusIn = "No";
            ShareInputState = "All";
            PreeditEnabledByDefault = false;
            ShowInputMethodInformation = true;
            showInputMethodInformationWhenFocusIn = false;
            CompactInputMethodInformation = true;
            ShowFirstInputMethodInformation = true;
            DefaultPageSize = 10;
            OverrideXkbOption = true;
            CustomXkbOption = "";
            EnabledAddons = "";
            DisabledAddons = "";
            PreloadInputMethod = true;
            AllowInputMethodForPassword = true;
            ShowPreeditForPassword = true;
            AutoSavePeriod = 30;
          };
        };
        inputMethod = {
          "Groups/0" = {
            Name = "Colemak+Chinese";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us-colemak";
          };

          "Groups/0/Items/0" = {
            Name = "rime";
            Layout = "";
          };

          "Groups/0/Items/1" = {
            Name = "keyboard-us-colemak";
            Layout = "";
          };

          "Groups/1" = {
            Name = "US";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };

          "Groups/1/Items/0" = {
            Name = "keyboard-us";
            Layout = "";
          };

          "GroupOrder" = {
            "0" = "Colemak+Chinese";
            "1" = "US";
          };
        };
      };
    };
  };
}
