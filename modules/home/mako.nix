{ config, pkgs, lib, ... }:

{
  services.mako = {
    enable = true;

    settings = {
      # ── 位置與大小 ──────────────────────────────────────────────
      anchor  = "top-right";
      width   = 340;
      height  = 120;
      margin  = "12";
      padding = "12 16";

      # ── 外觀（Catppuccin Mocha）────────────────────────────────
      background-color = "#1e1e2eff";
      text-color       = "#cdd6f4ff";
      border-color     = "#89b4faff";
      border-radius    = 8;
      border-size      = 2;

      # ── 行為 ────────────────────────────────────────────────────
      default-timeout = 5000;    # 5 秒後消失
      max-visible     = 5;
      sort            = "-time"; # 最新的通知在最上方
      layer           = "overlay";

      # ── 字型 ────────────────────────────────────────────────────
      font = "Noto Sans CJK TC 12";

      # ── 圖示 ────────────────────────────────────────────────────
      icons         = true;
      max-icon-size = 48;
      icon-path     = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
    };

    # ── 額外設定（urgency 分級）─────────────────────────────────
    extraConfig = ''
      # 緊急通知：紅色邊框、不自動消失
      [urgency=high]
      border-color=#f38ba8ff
      background-color=#1e1e2eff
      text-color=#f38ba8ff
      default-timeout=0

      # 低優先通知：綠色邊框
      [urgency=low]
      border-color=#a6e3a1ff
      default-timeout=3000

      # 點擊通知後消失
      on-notify=exec mako --dismiss-by-click
    '';
  };
}
