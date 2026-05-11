{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      # ── 字型 ──────────────────────────────────────────────────
      "font-family" = "Maple Mono NF";
      "font-size"   = 13;

      # ── 視窗外觀 ──────────────────────────────────────────────
      "background-opacity"    = 0.72;
      "window-decoration"     = false;
      "confirm-close-surface" = false;
      "window-padding-x"      = 0;
      "window-padding-y"      = 0;

      # ── cursor ───────────────────────────────────────────────
      "cursor-style"       = "block";
      "cursor-color"       = "#FFB4AB";
      "cursor-text-color"  = "#141311";

      # ── 配色 ──────────────────────────────────────────────────
      background            = "#141311";
      foreground            = "#CFC6A9";
      "selection-background" = "#CCC6B8";
      "selection-foreground" = "#211F1D";

      palette = [
        "0=#211F1D"
        "1=#A66359"
        "2=#6F895C"
        "3=#AB9349"
        "4=#627394"
        "5=#93627E"
        "6=#62938F"
        "7=#CCC6B8"
        "8=#49473D"
        "9=#FFB4AB"
        "10=#BFCAB4"
        "11=#CFC6A9"
        "12=#A9B5C6"
        "13=#C6A9BA"
        "14=#ADC2C1"
        "15=#DDD7C3"
      ];

      # ── 行為 ──────────────────────────────────────────────────
      "copy-on-select"          = true;
      "scrollback-limit"        = 10000;
      "mouse-hide-while-typing" = true;
    };

    keybindings = {
      "ctrl+shift+c"     = "copy_to_clipboard";
      "ctrl+shift+v"     = "paste_from_clipboard";
      "ctrl+equal"       = "increase_font_size";
      "ctrl+minus"       = "decrease_font_size";
      "ctrl+0"           = "reset_font_size";
      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+t"     = "new_tab";
      "ctrl+shift+l"     = "next_tab";
      "ctrl+shift+h"     = "previous_tab";
    };
  };
}
