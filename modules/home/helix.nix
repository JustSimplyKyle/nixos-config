{ pkgs, ... }:

let
  withWakatime = map (
    lang:
    lang
    // {
      language-servers = (lang.language-servers or [ ]) ++ [ "wakatime" ];
    }
  );

  managedLanguages =
    withWakatime [
      {
        name = "markdown";
        language-servers = [ "marksman" ];
      }
      {
        name = "rust";
        language-servers = [ "rust-analyzer" ];
      }
      {
        name = "nix";
        language-servers = [ "nil" ];
        formatter = {
          command = "nixfmt";
        };
        auto-format = true;
      }
      {
        name = "typst";
        language-servers = [ "tinymist" ];
      }
    ]
    ++ [ ];

in
{
  home.packages = with pkgs; [
    helix
    cmake-language-server
    jsonnet-language-server
    luaformatter
    lua-language-server
    marksman
    taplo
    nil
    nixd
    nixfmt-rfc-style
    jq-lsp
    tinymist
    vscode-langservers-extracted
    bash-language-server
    awk-language-server
    vscode-extensions.llvm-vs-code-extensions.vscode-clangd
    clang-tools
    docker-compose-language-service
    docker-compose
    docker-language-server
    typescript-language-server
    rust-analyzer
  ];

  programs.helix = {
    enable = true;

    languages = {
      language-server = {
        wakatime = {
          command = "wakatime-ls";
        };
        nil = {
          command = "nil";
        };
        lua = {
          command = "lua-language-server";
        };
        json = {
          command = "vscode-json-languageserver";
        };
        markdown = {
          command = "marksman";
        };

        tinymist = {
          command = "tinymist";
          config = {
            preview.background.enabled = true;
            formatterMode = "typestyle";
            lint.enabled = true;
            preview.background.args = [
              "--data-plane-host=127.0.0.1:0"
              "--invert-colors=never"
              "--open"
            ];
          };
        };

        rust-analyzer.config = {
          procMacro = true;
          cargo = {
            loadOutDirsFromCheck = true;
            allFeatures = false;
          };
          check = {
            command = "clippy";
            extraArgs = [
              "--"
              "-W"
              "clippy::pedantic"
              "-W"
              "clippy::nursery"
              "-A"
              "clippy::default_trait_access"
              "-A"
              "clippy::ptr_as_ptr"
              "-A"
              "clippy::wildcard_imports"
              "-A"
              "clippy::cast-precision-loss"
              "-A"
              "clippy::module_name_repetitions"
              "-W"
              "clippy::unwrap-used"
              "-W"
              "clippy::rc-buffer"
              "-W"
              "clippy::get_unwrap"
              "-A"
              "clippy::explicit_deref_methods"
            ];
          };
        };
      };

      language = managedLanguages;
    };

    settings = {
      theme = "fleet_dark";

      editor = {
        scrolloff = 10;
        line-number = "relative";
        color-modes = true;
        cursorline = true;
        true-color = true;
        idle-timeout = 0;
        completion-replace = true;

        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "error";
        };

        soft-wrap.enable = true;

        terminal = {
          command = "footclient";
          args = [
            "sh"
            "-c"
          ];
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "block";
        };

        lsp = {
          display-inlay-hints = true;
          display-messages = true;
        };

        indent-guides.render = true;
      };

      keys = {
        normal = {
          C-n = '':! echo -e "\e]52;;$(echo %{buffer_name} | base64)\007" > /dev/tty'';

          n = "move_line_down";
          e = "move_line_up";
          i = "move_char_right";
          F = "move_next_long_word_end";
          f = "move_next_word_end";
          T = "till_prev_char";
          t = "find_till_char";

          r = "select_regex";
          R = "split_selection";
          o = "collapse_selection";
          N = "join_selections";
          E = "keep_selections";

          p = "replace";
          P = "replace_with_yanked";
          u = "insert_mode";
          U = "insert_at_line_start";
          L = "redo";
          l = "undo";
          j = "yank";
          ";" = "paste_after";
          ":" = "paste_before";
          O = "command_mode";
          s = "delete_selection";
          y = "open_below";
          Y = "open_above";

          k = "search_next";
          K = "search_prev";

          z = {
            g = "align_view_top";
            n = "scroll_down";
            e = "scroll_up";
          };
          Z = {
            g = "align_view_top";
            n = "scroll_down";
            e = "scroll_up";
          };

          g = {
            d = "goto_file_start";
            f = "goto_last_line";
            t = "goto_file";
            i = "goto_line_end";
            r = "goto_first_nonwhitespace";
            g = "goto_window_top";
            s = "goto_definition";
            j = "goto_type_definition";
            p = "goto_reference";
            u = "goto_implementation";
            k = "goto_next_buffer";
            ";" = "goto_previous_buffer";
          };

          m = {
            r = "surround_add";
            p = "surround_replace";
            s = "surround_delete";
            u = "select_textobject_inner";
          };

          C-w = {
            r = "hsplit";
            t = "goto_file";
            T = "goto_file";
            n = "jump_view_down";
            e = "jump_view_up";
            i = "jump_view_right";
          };

          " " = {
            t = "file_picker";
            r = "symbol_picker";
            R = "workspace_symbol_picker";
            p = "rename_symbol";
            ";" = "paste_clipboard_after";
            ":" = "paste_clipboard_before";
            j = "yank_joined_to_clipboard";
            J = "yank_main_selection_to_clipboard";
            P = "replace_selections_with_clipboard";
            o = '':lsp-workspace-command tinymist.pinMain "%sh{realpath %{buffer_name}}"'';
          };

          "[" = {
            s = "goto_prev_diag";
            S = "goto_first_diag";
            t = "goto_prev_function";
            g = "goto_prev_class";
            G = "goto_prev_test";
            ";" = "goto_prev_paragraph";
            d = "goto_prev_change";
            D = "goto_last_change";
            "space" = "add_newline_above";
          };

          "]" = {
            s = "goto_next_diag";
            S = "goto_last_diag";
            t = "goto_next_function";
            g = "goto_next_class";
            G = "goto_next_test";
            ";" = "goto_next_paragraph";
            d = "goto_next_change";
            D = "goto_first_change";
          };
        };

        select = {
          n = "extend_line_down";
          e = "extend_line_up";
          i = "extend_char_right";
          F = "extend_next_long_word_end";
          f = "extend_next_word_end";
          T = "extend_prev_char";
          t = "extend_next_char";

          r = "select_regex";
          R = "split_selection";
          o = "collapse_selection";
          N = "join_selections";
          E = "keep_selections";

          p = "replace";
          P = "replace_with_yanked";
          u = "insert_mode";
          L = "redo";
          l = "undo";
          j = "yank";
          ";" = "paste_after";
          ":" = "paste_before";
          O = "command_mode";
          s = "delete_selection";
          y = "open_below";
          Y = "open_above";

          k = "search_next";
          K = "search_prev";

          z = {
            g = "align_view_top";
            n = "scroll_down";
          };
          Z = {
            g = "align_view_top";
            n = "scroll_down";
          };
          g = {
            d = "goto_file_start";
            f = "goto_last_line";
            t = "goto_file";
            i = "goto_line_end";
            r = "goto_first_nonwhitespace";
            g = "goto_window_top";
            s = "goto_definition";
            j = "goto_type_definition";
            p = "goto_reference";
            u = "goto_implementation";
            k = "goto_next_buffer";
            ";" = "goto_previous_buffer";
          };
          m = {
            r = "surround_add";
            p = "surround_replace";
            s = "surround_delete";
            u = "select_textobject_inner";
          };
          C-w = {
            r = "hsplit";
            t = "goto_file";
            T = "goto_file";
            n = "jump_view_down";
            e = "jump_view_up";
            i = "jump_view_right";
          };
          " " = {
            t = "file_picker";
            e = "hover";
            r = "symbol_picker";
            R = "workspace_symbol_picker";
            p = "rename_symbol";
            ";" = "paste_clipboard_after";
            ":" = "paste_clipboard_before";
            j = "yank_joined_to_clipboard";
            J = "yank_main_selection_to_clipboard";
            P = "replace_selections_with_clipboard";
          };
        };
      };
    };
  };
}
