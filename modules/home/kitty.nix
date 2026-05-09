{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 13;
    };

    settings = {
      # ── 視窗外觀 ──────────────────────────────────────────────
      background_opacity   = "0.95";
      window_padding_width = "12";
      confirm_os_window_close = "0";
      hide_window_decorations = "yes";   # 由 niri 管理裝飾

      # ── Catppuccin Mocha 配色 ─────────────────────────────────
      foreground            = "#CDD6F4";
      background            = "#1E1E2E";
      selection_foreground  = "#1E1E2E";
      selection_background  = "#F5E0DC";
      cursor                = "#F5E0DC";
      cursor_text_color     = "#1E1E2E";
      url_color             = "#F5E0DC";
      url_style             = "curly";

      # 一般色彩
      color0  = "#45475A";   # 黑（暗）
      color1  = "#F38BA8";   # 紅
      color2  = "#A6E3A1";   # 綠
      color3  = "#F9E2AF";   # 黃
      color4  = "#89B4FA";   # 藍
      color5  = "#F5C2E7";   # 洋紅
      color6  = "#94E2D5";   # 青
      color7  = "#BAC2DE";   # 白（暗）
      # 亮色彩
      color8  = "#585B70";
      color9  = "#F38BA8";
      color10 = "#A6E3A1";
      color11 = "#F9E2AF";
      color12 = "#89B4FA";
      color13 = "#F5C2E7";
      color14 = "#94E2D5";
      color15 = "#A6ADC8";

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
