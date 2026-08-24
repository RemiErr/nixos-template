{ config, pkgs, ... }:

{
  # ── KDE Plasma 6（Wayland）───────────────────────────────────────
  services.desktopManager.plasma6.enable = true;

  # 並將 Plasma Wayland session 設為預設
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "plasma";
  };

  # ── Niri 視窗管理器 ──────────────────────────────────────────────
  # 安裝 niri 並提供 Wayland session 入口（/usr/share/wayland-sessions/）
  programs.niri.enable = false;

  # ── XDG Desktop Portal（Wayland 標準 D-Bus 服務）────────────────
  xdg.portal = {
    enable        = false;
    extraPortals  = with pkgs; [
      xdg-desktop-portal-gnome   # 檔案選擇、截圖等對話框
      xdg-desktop-portal-gtk     # GTK 後備
    ];
    config = {
      niri = {
        default = [ "gnome" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      common.default = [ "gtk" ];
    };
  };

  # ── 輕量圖形檔案管理 ────────────────────────────────────
  # 只啟用 Thunar 與必要後端，不安裝完整 Xfce 桌面。
  programs.thunar = {
    enable = false;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable    = false; # 回收站、遠端位置與掛載
  services.tumbler.enable = false; # 檔案縮圖
  services.udisks2.enable = false; # USB 等可移除儲存裝置

  # 讓 Electron / Chromium 應用優先使用原生 Wayland。
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ── 圖形加速 ────────────────────────────────────────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;   # 32-bit 應用程式（如 Steam）相容
  };

  # ── PipeWire 音訊 ───────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;   # PulseAudio 相容層
    jack.enable       = true;   # JACK 相容層（DAW 使用）
  };

  # ── 系統安全 ────────────────────────────────────────────────────
  security.polkit.enable = true;          # 應用程式權限請求
  services.gnome.gnome-keyring.enable = false;  # 密鑰儲存（SSH/GPG）

  # ── greetd 登入管理器（TUI 風格）────────────────────────────────
  services.greetd = {
    enable         = false;
    useTextGreeter = false;
    settings = {
      default_session = {
        # --remember：記住上次成功登入的使用者名稱
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        user    = "greeter";
      };
    };
  };

  # ── 系統字型（含中文）────────────────────────────────────────────
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans       # 中文無襯線體
      noto-fonts-cjk-serif      # 中文襯線體
      noto-fonts-color-emoji
      liberation_ttf
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      lxgw-wenkai-screen        # 霞鶩文楷（繁體中文顯示字型）
      maple-mono.NF-unhinted    # Maple Mono NF
    ];
    fontconfig = {
      defaultFonts = {
        serif     = [ "Noto Serif CJK TC" "Noto Serif" ];
        sansSerif = [ "Noto Sans CJK TC"  "Noto Sans" ];
        monospace = [ "Maple Mono NF" "JetBrainsMono Nerd Font" "Noto Sans Mono CJK TC" ];
        emoji     = [ "Noto Color Emoji" ];
      };
    };
  };
}
