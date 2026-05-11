{ config, pkgs, lib, ... }:

{
  # ── Nix / Flakes 設定 ────────────────────────────────────────────
  nix.settings = {
    experimental-features  = [ "nix-command" "flakes" ];
    auto-optimise-store    = true;
    trusted-users          = [ "root" "@wheel" ];
    # 加速二進位快取
    substituters           = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys    = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # 自動垃圾回收
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 30d";
  };

  # ── 開機引導（UEFI / systemd-boot）─────────────────────────────
  boot.loader = {
    systemd-boot = {
      enable              = true;
      configurationLimit  = 5;     # 保留最近 5 個世代
      editor              = false; # 禁用啟動參數編輯（安全）
    };
    efi.canTouchEfiVariables = true;
  };

  # ── 時區與語系 ───────────────────────────────────────────────────
  time.timeZone = "Asia/Taipei";

  i18n = {
    defaultLocale = "zh_TW.UTF-8";
    extraLocaleSettings = {
      LC_ALL      = "zh_TW.UTF-8";
      LC_TIME     = "zh_TW.UTF-8";
      LC_MONETARY = "zh_TW.UTF-8";
    };
    supportedLocales = [
      "zh_TW.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  # 主控台（TTY）字型
  console = {
    font   = "Lat2-Terminus16";
    keyMap = "us";
  };

  # ── 基本系統套件 ─────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git
    vim
    neovim
    wget
    curl
    htop
    unzip
    zip
    p7zip
    ripgrep
    fd
    tree
    file
    which
    lsof
    pciutils
    usbutils
    man-pages
    linux-manual
  ];

  # ── Fish Shell 系統層級支援 ──────────────────────────────────────
  programs.fish.enable = true;
  environment.pathsToLink = [ "/share/fish" ];
  # fish 安裝時會產生 man cache，停用以加速 build
  documentation.man.generateCaches = false;

  # ── SSH 服務 ─────────────────────────────────────────────────────
  services.openssh = {
    enable   = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin        = "no";
    };
  };

  # ── 防火牆 ───────────────────────────────────────────────────────
  networking.firewall.enable = true;
}
