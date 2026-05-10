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
      background_opacity   = "1.0";
      background_blur      = 1;        # 需要 niri ≥ v26.04
      window_padding_width = "0";
      confirm_os_window_close = "0";
      hide_window_decorations = "yes";   # 由 niri 管理裝飾

      # ── cursor ───────────────────────────────────────────────
      cursor_shape = "block";
      cursor_trail = 1;

      # ── 配色 ──────────────────────────────────────────────────
      foreground            = "#dfdedb";
      background            = "#182029";
      cursor                = "#e0e2e8";
      cursor_text_color     = "#c2c7ce";
      selection_foreground  = "#23323f";
      selection_background  = "#a8c2d3";
      url_color             = "#79c9dd";
      url_style             = "curly";

      # 一般色彩
      color0  = "#524249";   # 黑（暗）
      color1  = "#cd8797";   # 紅
      color2  = "#92c09d";   # 綠
      color3  = "#cacd9f";   # 黃
      color4  = "#88b6f2";   # 藍
      color5  = "#cca3cf";   # 洋紅
      color6  = "#98bdc7";   # 青
      color7  = "#d1e3ee";   # 白（暗）
      # 亮色彩
      color8  = "#757388";
      color9  = "#e3929a";
      color10 = "#9dd6a0";
      color11 = "#dccba2";
      color12 = "#96a2d7";
      color13 = "#dea9d6";
      color14 = "#9adbca";
      color15 = "#bdcede";

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
