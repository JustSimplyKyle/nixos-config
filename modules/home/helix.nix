{ pkgs, ... }: {
  home.packages = with pkgs; (
    [
      helix
      cmake-language-server
      jsonnet-language-server
      luaformatter
      lua-language-server
      marksman
      taplo
      nil
      jq-lsp
      vscode-langservers-extracted
      bash-language-server
      awk-language-server
      vscode-extensions.llvm-vs-code-extensions.vscode-clangd
      clang-tools
      docker-compose-language-service
      docker-compose
      docker-language-server
      typescript-language-server
    ]
  );

  home.file.".config/helix/languages.toml".text =
    ''
      [language-server.nil]
      command = "nil"

      [language-server.lua]
      command = "lua-language-server"

      [language-server.json]
      command = "vscode-json-languageserver"

      [language-server.markdown]
      command = "marksman"
    '';

  home.file.".config/helix/config.toml".text =
    ''
      theme = "fleet_dark"

      [editor]
      scrolloff = 10
      line-number = "relative"
      color-modes = true
      cursorline = true
      true-color = true
      idle-timeout = 0
      completion-replace = true

      [editor.inline-diagnostics]
      cursor-line = "hint"
      other-lines = "error"

      [editor.soft-wrap]
      enable = true

      [editor.terminal]
      command = "footclient"
      args = [ "sh", "-c" ]

      [editor.cursor-shape]
      insert = "bar"
      normal = "block"
      select = "block"

      [editor.lsp]
      display-inlay-hints = true
      display-messages = true

      [editor.indent-guides]
      render = true

      [keys.normal]
      # movement
      n = "move_line_down"
      e = "move_line_up" 
      i = "move_char_right"
      F = "move_next_long_word_end"
      f = "move_next_word_end"
      T = "till_prev_char"
      t = "find_till_char"
      # T = "find_prev_char"
      # t = "find_next_char"
      # selection manipulation
      r = "select_regex"
      R = "split_selection"
      o = "collapse_selection"
      N = "join_selections"
      E = "keep_selections"



      # Changes
      p = "replace"
      P = "replace_with_yanked"
      u = "insert_mode"
      U = "insert_at_line_start"
      L = "redo"
      l = "undo"
      j = "yank"
      ";" = "paste_after"
      ":" = "paste_before"
      O = "command_mode"
      s = "delete_selection"
      y = "open_below"
      Y = "open_above"



      # search
      k = "search_next"
      K = "search_prev"

      # view mode
      [keys.normal.z]
      g = "align_view_top"
      n = "scroll_down"
      e = "scroll_up"
      # sticky view mode(copy the normal view)
      [keys.normal.Z]
      g = "align_view_top"
      n = "scroll_down"
      e = "scroll_up"

      # goto mode
      [keys.normal.g]
      d = "goto_file_start"
      f = "goto_last_line"
      t = "goto_file"
      i = "goto_line_end"
      r = "goto_first_nonwhitespace"
      g = "goto_window_top"
      s = "goto_definition"
      j = "goto_type_definition"
      p = "goto_reference"
      u = "goto_implementation"
      k = "goto_next_buffer"
      ";" = "goto_previous_buffer"

      # match mode todo
      [keys.normal.m]
      r = "surround_add"
      p = "surround_replace"
      s = "surround_delete"
      u = "select_textobject_inner"

      # window mode todo
      [keys.normal.C-w]
      r = "hsplit"
      t = "goto_file"
      T = "goto_file"
      n = "jump_view_down"
      e = "jump_view_up"
      i = "jump_view_right"
      # Space mode
      [keys.normal." "]
      t = "file_picker"
      # e = "hover"
      r = "symbol_picker"
      R = "workspace_symbol_picker"
      "o" = ':lsp-workspace-command tinymist.pinMain "%sh{realpath %{buffer_name}}"'
      p = "rename_symbol"
      ";" = "paste_clipboard_after"
      ":" = "paste_clipboard_before"
      j = "yank_joined_to_clipboard"
      J = "yank_main_selection_to_clipboard"
      P = "replace_selections_with_clipboard"

      # select 
      [keys.select]
      # movement
      n = "extend_line_down"
      e = "extend_line_up"
      i = "extend_char_right"
      F = "extend_next_long_word_end"
      f = "extend_next_word_end"
      # G = "extend_till_prev_char"
      # g = "extend_till_char"
      T = "extend_prev_char"
      t = "extend_next_char"
      # selection manipulation
      r = "select_regex"
      R = "split_selection"
      o = "collapse_selection"
      N = "join_selections"
      E = "keep_selections"



      # Changes
      p = "replace"
      P = "replace_with_yanked"
      u = "insert_mode"
      L = "redo"
      l = "undo"
      j = "yank"
      ";" = "paste_after"
      ":" = "paste_before"
      O = "command_mode"
      s = "delete_selection"
      y = "open_below"
      Y = "open_above"



      # search
      k = "search_next"
      K = "search_prev"

      # view mode
      [keys.select.z]
      g = "align_view_top"
      n = "scroll_down"
      # sticky view mode(copy the normal view)
      [keys.select.Z]
      g = "align_view_top"
      n = "scroll_down"
      # goto mode
      [keys.select.g]
      d = "goto_file_start"
      f = "goto_last_line"
      t = "goto_file"
      i = "goto_line_end"
      r = "goto_first_nonwhitespace"
      g = "goto_window_top"
      s = "goto_definition"
      j = "goto_type_definition"
      p = "goto_reference"
      u = "goto_implementation"
      k = "goto_next_buffer"
      ";" = "goto_previous_buffer"

      # match mode todo
      [keys.select.m]
      r = "surround_add"
      p = "surround_replace"
      s = "surround_delete"
      u = "select_textobject_inner"

      # window mode todo
      [keys.select.C-w]
      r = "hsplit"
      t = "goto_file"
      T = "goto_file"
      n = "jump_view_down"
      e = "jump_view_up"
      i = "jump_view_right"
      # Space mode
      [keys.select." "]
      t = "file_picker"
      e = "hover"
      r = "symbol_picker"
      R = "workspace_symbol_picker"
      p = "rename_symbol"
      ";" = "paste_clipboard_after"
      ":" = "paste_clipboard_before"
      j = "yank_joined_to_clipboard"
      J = "yank_main_selection_to_clipboard"
      P = "replace_selections_with_clipboard"

      [keys.normal."["]
      s = "goto_prev_diag"
      S = "goto_first_diag"
      t = "goto_prev_function"
      g = "goto_prev_class"
      G = "goto_prev_test"
      ';' = "goto_prev_paragraph"
      d = "goto_prev_change"
      D = "goto_last_change"
      "space" = "add_newline_above"

      [keys.normal."]"]
      s = "goto_next_diag"
      S = "goto_last_diag"
      t = "goto_next_function"
      g = "goto_next_class"
      G = "goto_next_test"
      ';' = "goto_next_paragraph"
      d = "goto_next_change"
      D = "goto_first_change"
    '';
}
