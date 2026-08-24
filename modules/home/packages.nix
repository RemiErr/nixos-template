{ pkgs, ... }:

{
  # ── 共用工具套件 ─────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Home Manager 管理自己
    inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default

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
    librewolf
    brave

    # 編輯器（選用）
    vscode
  ];
}