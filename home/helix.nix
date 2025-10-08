{ ... }:
{

  programs.helix.enable = true;
  programs.helix.settings = {

    theme = "curzon";
    editor = {
      line-number = "relative";
      color-modes = true; # curzon doesn't have colors for modes, but still :sweat_smile:
      auto-pairs = false; # >:(
      lsp = {
        display-inlay-hints = true;
      };
      file-picker = {
        hidden = true;
      };
      inline-diagnostics = {

        cursor-line = "hint";
        other-lines = "error";
      };
    };
    keys.normal = {
      # https://github.com/helix-editor/helix/issues/13187,
      # https://github.com/helix-editor/helix/pull/12203
      "D" = ":toggle inline-diagnostics.cursor-line hint disable";
      "C-D" = ":toggle inline-diagnostics.other-lines error disable";

      "A-z" = ":toggle soft-wrap.enable";
    };
  };
}
