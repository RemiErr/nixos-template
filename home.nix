{ config, pkgs, vars, ... }:

{
  imports = [
    # inputs.noctalia.homeModules.default  # Noctalia（桌面 shell，v5）
    # ./modules/home/noctalia.nix
    # ./modules/home/niri.nix
    ./modules/home/fish.nix
    # ./modules/home/foot.nix
    ./modules/home/fastfetch.nix
    ./modules/home/packages.nix
  ];

  # ── 使用者資訊 ───────────────────────────────────────────────────
  home.username      = vars.username;
  home.homeDirectory = vars.homeDirectory;

  # ── 環境變數 ─────────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = vars.editor;
  };

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

  home.stateVersion = vars.stateVersion;
}
