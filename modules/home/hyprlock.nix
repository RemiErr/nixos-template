{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [ hyprlock ];

  # ── hyprlock 設定 ────────────────────────────────────────────────
  # hyprlock 使用 ext-session-lock-v1 Wayland 協定，與 niri 相容
  # 文件：https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/
  xdg.configFile."hypr/hyprlock.conf".text = ''
    general {
        grace       = 0       # 喚醒後幾秒內不需要密碼（0 = 立即要求）
        hide_cursor = true
        no_fade_in  = false
    }

    background {
        monitor  =
        # 使用壁紙作為鎖屏背景（若不存在則使用純色）
        path     = ~/Pictures/Wallpapers/default.jpg
        color    = rgba(30, 30, 46, 1.0)   # Catppuccin Mocha base（後備色）

        blur_passes    = 3
        blur_size      = 4
        noise          = 0.012
        contrast       = 0.89
        brightness     = 0.82
        vibrancy       = 0.17
        vibrancy_darkness = 0.0
    }

    # ── 時間顯示 ─────────────────────────────────────────────────
    label {
        monitor  =
        text     = cmd[update:1000] echo "$(date +'%H:%M')"
        color    = rgba(205, 214, 244, 1.0)
        font_size   = 72
        font_family = JetBrainsMono Nerd Font Bold

        shadow_passes   = 3
        shadow_size     = 4
        shadow_color    = rgba(0, 0, 0, 0.6)
        shadow_boost    = 1.2

        position = 0, 80
        halign   = center
        valign   = center
    }

    # ── 日期顯示 ─────────────────────────────────────────────────
    label {
        monitor  =
        text     = cmd[update:60000] echo "$(date +'%Y 年 %-m 月 %-d 日 %A')"
        color    = rgba(186, 194, 222, 0.9)
        font_size   = 18
        font_family = Noto Sans CJK TC

        position = 0, 10
        halign   = center
        valign   = center
    }

    # ── 密碼輸入框 ───────────────────────────────────────────────
    input-field {
        monitor  =
        size     = 260, 52
        outline_thickness = 2
        dots_size         = 0.25
        dots_spacing      = 0.2
        dots_center       = true
        dots_rounding     = -1

        outer_color = rgba(137, 180, 250, 1.0)   # Blue
        inner_color = rgba(30, 30, 46, 0.85)
        font_color  = rgba(205, 214, 244, 1.0)
        check_color = rgba(166, 227, 161, 1.0)   # Green（密碼驗證中）
        fail_color  = rgba(243, 139, 168, 1.0)   # Red（密碼錯誤）

        fail_text       = 密碼錯誤
        placeholder_text = <i>請輸入密碼...</i>
        hide_input      = false
        rounding        = 8
        fade_on_empty   = false

        position = 0, -160
        halign   = center
        valign   = center
    }

    # ── 使用者名稱 ───────────────────────────────────────────────
    label {
        monitor  =
        text     = $USER
        color    = rgba(137, 180, 250, 0.8)
        font_size   = 14
        font_family = JetBrainsMono Nerd Font

        position = 0, -220
        halign   = center
        valign   = center
    }
  '';
}
