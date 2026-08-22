{ config, pkgs, inputs, lib, vars, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default  # Noctalia（桌面 shell，v5）
    ../modules/home/niri.nix        # 視窗管理器與鍵位設定
    ../modules/home/fish.nix       # Shell
    ../modules/home/foot.nix       # 終端機
    ../modules/home/fastfetch.nix   # 系統資訊
  ];

  # ── 使用者資訊 ───────────────────────────────────────────────────
  home.username      = vars.username;
  home.homeDirectory = vars.homeDirectory;

  # ── 環境變數 ─────────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = vars.editor;
  };

  # ── 共用工具套件 ─────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Wayland 截圖工具組
    grim          # 截圖（整個螢幕或指定區域）
    slurp         # 互動式選取區域
    swappy        # 截圖後標註工具

    # 剪貼簿
    wl-clipboard  # wl-copy / wl-paste

    # 通知 CLI
    libnotify     # notify-send

    # XDG 工具
    xdg-utils     # xdg-open、xdg-mime 等
    xdg-user-dirs

    # 系統控制
    brightnessctl # 亮度
    playerctl     # 媒體播放控制（MPRIS）
    pamixer       # PulseAudio / PipeWire 音量
    pavucontrol   # 音量控制 GUI

    # 系統監控
    btop

    # 網路工具
    networkmanagerapplet  # 系統匣網路圖示

    # 檔案管理器
    yazi          # 終端機檔案管理器

    # 圖片檢視
    imv           # Wayland 原生圖片檢視器

    # 影片播放（選用）
    # mpv
    vlc

    # 瀏覽器（選用）
    firefox
  ];

  # ── 字型設定 ────────────────────────────────────────────────────
  fonts.fontconfig.enable = true;

  # ── XDG 使用者目錄 ───────────────────────────────────────────────
  xdg = {
    enable = true;
    userDirs = {
      enable           = true;
      createDirectories = true;
      desktop   = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download  = "${config.home.homeDirectory}/Downloads";
      music     = "${config.home.homeDirectory}/Music";
      pictures  = "${config.home.homeDirectory}/Pictures";
      videos    = "${config.home.homeDirectory}/Videos";
    };
  };

  # ── Git 設定 ─────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user.name  = vars.git.name;
      user.email = vars.git.email;
      init.defaultBranch = "main";
      pull.rebase        = false;
      core.editor        = "nvim";
      diff.tool          = "vimdiff";

      alias = {
        st = "status";
        br = "branch";
        co = "checkout";
        cm = "commit -m";
        ca = "commit -am";
        dc = "diff --cached";
      };
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      "*.env"
      ".direnv"
      "result"
    ];
  };

  # ── Noctalia（v5，設定改為 TOML schema，經 tomlFormat 由此 attrset 產生）───
  # 完整 schema 參考 https://docs.noctalia.dev/noctalia/
  # v4 有、但 v5 目前文件中找不到對應設定的項目，先移除：
  # （enableBlurBehind、panelBackgroundOpacity、panelsAttachedToBar、tooltipsEnabled、fontFixed、
  # largeButtonsStyle、sessionMenu 的 position/showHeader、ControlCenter 的 useDistroLogo）
  # 等 v5 出穩定版後，再回頭確認是否已新增等效設定。
  programs.noctalia = {
    enable = true;
    settings = {
      shell = {
        font_family       = "JetBrainsMono Nerd Font";
        time_format       = "%H\n%M";                # 對應舊 general.clockFormat = "hh\\nmm"
        corner_radius_scale = 1.0;                     # 對應舊 general.radiusRatio
        telemetry_enabled = false;

        animation = {
          enabled = true;
          speed   = 1.0;
        };

        session = {
          grid           = true;                        # 對應舊 largeButtonsLayout = "grid"
          show_shortcuts = true;                         # 對應舊 showKeybinds

          actions = [
            { action = "lock";     enabled = true; shortcut = "1"; countdown_seconds = 10; }
            { action = "suspend";  enabled = true; shortcut = "2"; countdown_seconds = 10; }
            # v5 內建 action 列舉沒有 hibernate/rebootToUefi，改用 command 自訂
            { action = "command";  enabled = true; shortcut = "3"; countdown_seconds = 10; label = "Hibernate";       glyph = "moon";    command = "systemctl hibernate"; }
            { action = "reboot";   enabled = true; shortcut = "4"; countdown_seconds = 10; }
            { action = "logout";   enabled = true; shortcut = "5"; countdown_seconds = 10; }
            { action = "shutdown"; enabled = true; shortcut = "6"; countdown_seconds = 10; }
            { action = "command";  enabled = true;                                          label = "Reboot to UEFI"; glyph = "settings"; command = "systemctl reboot --firmware-setup"; }
          ];
        };
      };

      theme = {
        mode            = "dark";                     # 對應舊 colorSchemes.darkMode
        source          = "wallpaper";                # 對應舊 colorSchemes.useWallpaperColors
        wallpaper_scheme = "m3-tonal-spot";            # 對應舊 generationMethod = "tonal-spot"
      };

      notification = {
        enable_daemon       = true;
        position            = "top_right";
        collapse_on_dismiss = true;                    # 對應舊 clearDismissed
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
        order = [ "main" ];
        main = {
          position            = "top";
          background_opacity  = 0.2;
          radius              = 12;                     # 對應舊 frameRadius
          concave_edge_corners = true;                   # 對應舊 outerCorners
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
          format = "%H:%M %a, %b %d";                  # 對應舊 formatHorizontal = "HH:mm ddd, MMM dd"
        };

        active_window = {
          max_length = 145;
          display    = "icon_and_text";
        };

        workspaces = {
          label_source              = "id";             # 對應舊 labelMode = "index"
          labels_only_when_occupied = false;             # 對應舊 hideUnoccupied = false
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

  # ── Home Manager 管理自身 ────────────────────────────────────────
  programs.home-manager.enable = true;
  home.stateVersion = vars.stateVersion;
}
