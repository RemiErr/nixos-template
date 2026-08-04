{ config, pkgs, inputs, lib, vars, ... }:

{
  imports = [
    inputs.noctalia-shell.homeModules.default  # Noctalia Shell（桌面 shell）
    ../modules/home/niri.nix        # 視窗管理器與鍵位設定
    ../modules/home/fish.nix       # Shell
    ../modules/home/foot.nix       # 終端機
    ../modules/home/hyprlock.nix    # 鎖屏
    ../modules/home/fastfetch.nix   # 系統資訊
    # ../modules/home/waybar.nix    # 狀態列（改用 noctalia-shell Bar）
    # ../modules/home/mako.nix      # 通知（改用 noctalia-shell Notification）
    # ../modules/home/swww.nix      # 桌布管理（改用 noctalia-shell Background）
    # ../modules/home/wlogout.nix   # 登出選單（改用 noctalia-shell SessionMenu）
    # ../modules/home/fuzzel.nix    # 應用程式啟動器（改用 noctalia AppLauncher）
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
    # vlc

    # 瀏覽器（選用）
    # firefox
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

  # ── Noctalia Shell ───────────────────────────────────────────────
  programs.noctalia-shell = {
    enable = true;
    settings = {
      appLauncher = {
        terminalCommand = "foot -e";
      };
      bar = {
        position = "top";
        backgroundOpacity = 0.2;
        frameRadius = 12;
        barType = "simple";
        # displayMode = "auto_hide";
        autoHideDelay = 500;
        autoShowDelay = 150;
        widgetSpacing = 6;
        outerCorners = true;
        widgets = {
          left = [
            { id = "Launcher"; icon = "rocket"; }
            { id = "Clock"; formatHorizontal = "HH:mm ddd, MMM dd"; }
            { id = "ActiveWindow"; maxWidth = 145; showIcon = true; showText = true; hideMode = "hidden"; }
          ];
          center = [
            { id = "Workspace"; labelMode = "index"; hideUnoccupied = false; }
          ];
          right = [
            { id = "NotificationHistory"; showUnreadBadge = true; }
            { id = "Volume"; middleClickCommand = "pavucontrol"; }
            { id = "Brightness"; }
            { id = "Tray"; }
            { id = "ControlCenter"; icon = "noctalia"; useDistroLogo = true; }
          ];
        };
      };
      colorSchemes = {
        darkMode = true;
        generationMethod = "tonal-spot";
        useWallpaperColors = true;
      };
      ui = {
        fontDefault = "JetBrainsMono Nerd Font";
        fontFixed = "JetBrainsMono Nerd Font";
        panelBackgroundOpacity = 0.85;
        panelsAttachedToBar = true;
        tooltipsEnabled = true;
      };
      notifications = {
        location = "top_right";
        clearDismissed = true;
        enabled = true;
      };
      general = {
        animationSpeed = 1;
        animationDisabled = false;
        telemetryEnabled = false;
        enableBlurBehind = true;
        enableShadows = true;
        clockFormat = "hh\\nmm";
        clockStyle = "custom";
        radiusRatio = 1;
      };
      sessionMenu = {
        countdownDuration  = 10000;
        enableCountdown    = true;
        largeButtonsLayout = "grid";
        largeButtonsStyle  = true;
        position           = "center";
        showHeader         = true;
        showKeybinds       = true;
        powerOptions = [
          { action = "lock";         command = ""; countdownEnabled = true; enabled = true; keybind = "1"; }
          { action = "suspend";      command = ""; countdownEnabled = true; enabled = true; keybind = "2"; }
          { action = "hibernate";    command = ""; countdownEnabled = true; enabled = true; keybind = "3"; }
          { action = "reboot";       command = ""; countdownEnabled = true; enabled = true; keybind = "4"; }
          { action = "logout";       command = ""; countdownEnabled = true; enabled = true; keybind = "5"; }
          { action = "shutdown";     command = ""; countdownEnabled = true; enabled = true; keybind = "6"; }
          { action = "rebootToUefi"; command = ""; countdownEnabled = true; enabled = true; keybind = "";  }
        ];
      };
    };
  };

  # ── Home Manager 管理自身 ────────────────────────────────────────
  programs.home-manager.enable = true;

  # !! 必須與 system.stateVersion 一致 !!
  home.stateVersion = "26.05";
}
