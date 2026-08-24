{ config, pkgs, vars, ... }:

{
  imports = [
    # inputs.noctalia.homeModules.default  # Noctalia（桌面 shell，v5）
    # ./modules/home/noctalia.nix
    # ./modules/home/niri.nix
    ./modules/home/fish.nix
    # ./modules/home/foot.nix
    ./modules/home/fastfetch.nix
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
    # grim          # 截圖（整個螢幕或指定區域）
    # slurp         # 互動式選取區域
    # swappy        # 截圖後標註工具

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
    # networkmanagerapplet  # 系統匣網路圖示

    # 檔案管理器
    yazi          # 終端機檔案管理器

    # 文件與壓縮檔
    # mousepad      # 輕量圖形文字編輯器
    # zathura       # 輕量 PDF 閱讀器
    # xarchiver     # 圖形壓縮檔管理器

    # 圖片檢視
    # imv           # Wayland 原生圖片檢視器

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
    mimeApps = {
      enable = true;
      defaultApplications."x-scheme-handler/steam" = "steam.desktop";
      defaultApplicationPackages = with pkgs; [
        kdePackages.dolphin   # 目錄
        kdePackages.ark       # 壓縮檔
        kdePackages.okular    # PDF
        kdePackages.kate      # 文字
        kdePackages.gwenview  # 圖片
        vlc                   # 影音
        firefox               # Web 與 URL scheme
      ];
    };
    userDirs = {
      enable            = true;
      createDirectories = true;
      desktop   = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download  = "${config.home.homeDirectory}/Downloads";
      music     = "${config.home.homeDirectory}/Music";
      pictures  = "${config.home.homeDirectory}/Pictures";
      videos    = "${config.home.homeDirectory}/Videos";
    };
  };

  # Niri 自動建立截圖的父目錄。
  # home.activation.createScreenshotDirectory =
  #   lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #     $DRY_RUN_CMD mkdir -p "${config.xdg.userDirs.pictures}/Screenshots"
  #   '';

  # ── Git 設定 ─────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user.name  = vars.git.name;
      user.email = vars.git.email;
      init.defaultBranch = "main";
      pull.rebase        = false;
      core.editor        = vars.editor;
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

  # ── Home Manager 管理自身 ────────────────────────────────────────
  programs.home-manager.enable = true;
  home.stateVersion = vars.stateVersion;
}
