{ config, pkgs, inputs, lib, vars, ... }:

{
  # ── Noctalia（v5，設定改為 TOML schema，經 tomlFormat 由此 attrset 產生）───
  # 完整 schema 參考 https://docs.noctalia.dev/noctalia/
  # v4 有、但 v5 目前文件中沒有對應設定的項目：
  # （enableBlurBehind、panelBackgroundOpacity、panelsAttachedToBar、tooltipsEnabled、fontFixed、
  # largeButtonsStyle、sessionMenu 的 position/showHeader、ControlCenter 的 useDistroLogo）
  #
  programs.noctalia = {
    enable = true;
    settings = {
      shell = {
        font_family       = "JetBrainsMono Nerd Font";
        time_format       = "{:%H\n%M}";               # v5 使用 {:…} 時間格式，保留兩行顯示
        corner_radius_scale = 1.0;                     # 對應舊 general.radiusRatio
        telemetry_enabled = false;
        polkit_agent      = true;

        animation = {
          enabled = true;
          speed   = 1.0;
        };

        session = {
          grid           = true;                        # 對應舊 largeButtonsLayout = "grid"
          show_shortcuts = true;                        # 對應舊 showKeybinds

          actions = [
            { action = "lock";     enabled = true; shortcut = "1"; countdown_seconds = 10; }
            { action = "suspend";  enabled = true; shortcut = "2"; countdown_seconds = 10; }
            { action = "reboot";   enabled = true; shortcut = "3"; countdown_seconds = 10; }
            { action = "logout";   enabled = true; shortcut = "4"; countdown_seconds = 10; }
            { action = "shutdown"; enabled = true; shortcut = "5"; countdown_seconds = 10; }

            # v5 內建 action 列舉沒有 rebootToUefi，改用 command 自訂
            { action = "command";  enabled = true; label = "Reboot to UEFI"; glyph = "settings"; command = "systemctl reboot --firmware-setup"; }
          ];
        };
      };

      theme = {
        mode            = "dark";                     # 對應舊 colorSchemes.darkMode
        source          = "wallpaper";                # 對應舊 colorSchemes.useWallpaperColors
        wallpaper_scheme = "m3-tonal-spot";           # 對應舊 generationMethod = "tonal-spot"
      };

      notification = {
        enable_daemon       = true;
        position            = "top_right";
        collapse_on_dismiss = true;                   # 對應舊 clearDismissed
      };

      # 原生鎖屏（取代 v4 的外部 hyprlock.nix）。外觀（時鐘樣式、模糊程度、
      # 桌布）用 lockscreen widget 編輯器（IPC: lockscreen-widgets-edit）
      # 執行期調整，這裡先只開啟並保留 v4 hyprlock.conf「睡眠前必定鎖屏」的行為。
      lockscreen = {
        enabled              = true;
        lock_before_suspend  = true;
        allow_empty_password = false;
      };

      # 注意：這裡一律用巢狀 attrset（bar.main、widget.launcher…）而非帶點的
      # 字串 key（"bar.main"）。後者會被 tomlFormat 序列化成單一個名字裡帶
      # 點的 TOML key，不等於 [bar.main] 這種巢狀 table，會讓 noctalia 讀不到。
      bar = {
        main = {
          position            = "top";
          background_opacity  = 0.2;
          radius              = 12;                     # 對應舊 frameRadius
          concave_edge_corners = true;                  # 對應舊 outerCorners
          widget_spacing      = 6;
          auto_hide           = false;

          start  = [ "launcher" "clock" "active_window" ];
          center = [ "workspaces" ];
          end    = [ "notifications" "volume" "brightness" "tray" "control-center" ];
        };
      };

      widget = {
        launcher = {
          glyph = "rocket";
        };

        clock = {
          format = "{:%H:%M %a, %b %d}";                # v5 clock widget 使用 {:…} 格式
        };

        active_window = {
          max_length = 145;
          display    = "icon_and_text";
        };

        workspaces = {
          label_source              = "id";             # 對應舊 labelMode = "index"
          labels_only_when_occupied = false;            # 對應舊 hideUnoccupied = false
        };

        notifications = {
          hide_when_no_unread = false;                  # 對應舊 showUnreadBadge = true（一律顯示數量徽章）
        };

        volume.actions = {
          middle = "exec pavucontrol";                  # 對應舊 middleClickCommand
        };

        control-center = {
          glyph = "noctalia";
        };
      };
    };
  };
}