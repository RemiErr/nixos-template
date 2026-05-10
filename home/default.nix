{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    inputs.noctalia-shell.homeModules.default  # Noctalia Shell（桌面 shell）
    ../modules/home/niri.nix        # 視窗管理器與鍵位設定
    ../modules/home/kitty.nix       # 終端機
    ../modules/home/fuzzel.nix      # 應用程式啟動器
    ../modules/home/hyprlock.nix    # 鎖屏
    ../modules/home/fastfetch.nix   # 系統資訊
    # ../modules/home/waybar.nix    # 狀態列（改用 noctalia-shell Bar）
    # ../modules/home/mako.nix      # 通知（改用 noctalia-shell Notification）
    # ../modules/home/swww.nix      # 桌布管理（改用 noctalia-shell Background）
    # ../modules/home/wlogout.nix   # 登出選單（改用 noctalia-shell SessionMenu）
  ];

  # ── 使用者資訊（必須與 NixOS users.users 一致）───────────────────
  # CHANGE: update both lines below and home-manager.users.<name> in flake.nix
  home.username      = "user";        # CHANGE: replace with your username
  home.homeDirectory = "/home/user";  # CHANGE: replace "user" with your username


  # ── 共用工具套件 ─────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Wayland 截圖工具組
    grim          # 截圖（整個螢幕或指定區域）
    slurp         # 互動式選取區域
    swappy        # 截圖後標註工具

    # 剪貼簿
    wl-clipboard  # wl-copy / wl-paste
    cliphist      # 剪貼簿歷史（配合 fuzzel 使用）

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

  # ── Bash 設定 ────────────────────────────────────────────────────
  programs.bash = {
    enable      = true;
    historySize = 10000;
    historyFileSize = 50000;
    historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
    shellAliases = {
      ll      = "ls -lahF --color=auto";
      la      = "ls -A --color=auto";
      grep    = "grep --color=auto";
      cls     = "clear";
      sos     = "source";
      py      = "python3";
      # NixOS 系統更新（改為你的 hostname）
      update  = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
      # Home Manager 更新
      hm      = "home-manager switch --flake ~/nixos-config#user@nixos"; # CHANGE: replace "user" with your username, "nixos" with your hostname
      # Nix 清理
      gc      = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      # 查詢目前世代
      gens    = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    };
    initExtra = ''
      # 彩色提示列
      PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '

      # 確保 ~/.local/bin 在 PATH 中
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  # ── Git 設定 ─────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user.name  = "Your Name";        # CHANGE: your Git display name
      user.email = "your@email.com";   # CHANGE: your Git email address
      init.defaultBranch = "main";
      pull.rebase        = false;
      core.editor        = "nvim";
      diff.tool          = "vimdiff";

      alias = {
        # common aliases
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
        terminalCommand = "kitty -e";  # 預設 xterm -e 未安裝，改為 kitty
      };
      bar = {
        position = "top";
        backgroundOpacity = 0.2;
        frameRadius = 12;
        barType = "simple";
        displayMode = "auto_hide";
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
    };
  };

  # ── Home Manager 管理自身 ────────────────────────────────────────
  programs.home-manager.enable = true;

  # !! 必須與 system.stateVersion 一致 !!
  home.stateVersion = "25.11";
}
