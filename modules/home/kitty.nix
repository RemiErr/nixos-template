{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = "Maple Mono NF";
      size = 13;
    };

    settings = {
      # ── 視窗外觀 ──────────────────────────────────────────────
      background_opacity   = "0.82";
      background_blur      = 20;       # 需要 niri ≥ v26.04
      window_padding_width = "0";
      confirm_os_window_close = "0";
      hide_window_decorations = "yes";   # 由 niri 管理裝飾

      # ── cursor ───────────────────────────────────────────────
      cursor_shape = "block";
      cursor_trail = 1;

      # ── 配色 ──────────────────────────────────────────────────
      foreground            = "#CFC6A9";
      background            = "#141311";
      cursor                = "#FFB4AB";
      cursor_text_color     = "#141311";
      selection_foreground  = "#211F1D";
      selection_background  = "#CCC6B8";
      url_color             = "#62938F";
      url_style             = "curly";

      # 一般色彩（dim）
      color0  = "#211F1D";   # 黑
      color1  = "#A66359";   # 紅
      color2  = "#6F895C";   # 綠
      color3  = "#AB9349";   # 黃
      color4  = "#627394";   # 藍
      color5  = "#93627E";   # 洋紅
      color6  = "#62938F";   # 青
      color7  = "#CCC6B8";   # 白
      # 亮色彩（bright）
      color8  = "#49473D";
      color9  = "#FFB4AB";
      color10 = "#BFCAB4";
      color11 = "#CFC6A9";
      color12 = "#A9B5C6";
      color13 = "#C6A9BA";
      color14 = "#ADC2C1";
      color15 = "#DDD7C3";

      # ── 行為 ──────────────────────────────────────────────────
      enable_audio_bell      = "no";
      visual_bell_duration   = "0.0";
      copy_on_select         = "yes";       # 選取即複製到剪貼簿
      strip_trailing_spaces  = "smart";
      scrollback_lines       = "10000";
      scrollback_pager_history_size = "0";

      # ── 效能 ──────────────────────────────────────────────────
      sync_to_monitor         = "yes";
      repaint_delay           = "10";
      input_delay             = "3";

      # ── 滑鼠 ──────────────────────────────────────────────────
      mouse_hide_wait         = "3.0";
      open_url_with           = "xdg-open";

      # ── 分頁 ──────────────────────────────────────────────────
      tab_bar_edge            = "bottom";
      tab_bar_style           = "powerline";
      tab_powerline_style     = "slanted";
      tab_title_template      = "{index}: {title}";

      # ── 中文輸入法相容 ────────────────────────────────────────
      # wayland_enable_ime = "yes"  # 若注音無法輸入，取消此注解
    };

    keybindings = {
      "ctrl+shift+c"     = "copy_to_clipboard";
      "ctrl+shift+v"     = "paste_from_clipboard";
      "ctrl+equal"       = "increase_font_size";
      "ctrl+minus"       = "decrease_font_size";
      "ctrl+0"           = "restore_font_size";
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+t"     = "new_tab_with_cwd";
      "ctrl+shift+l"     = "next_tab";
      "ctrl+shift+h"     = "previous_tab";
    };
  };
}
