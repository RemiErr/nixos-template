{ config, pkgs, lib, ... }:

{
  # ── fcitx5 輸入法框架 + 新注音（chewing）────────────────────────
  #
  # NixOS 會自動：
  #   1. 安裝 fcitx5 及指定附加元件
  #   2. 注入必要環境變數
  #   3. 透過 XDG autostart 啟動
  #
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";                     # NixOS 25.05+ 語法（enabled 為舊語法）
    fcitx5 = {
      waylandFrontend = true;            # 使用 Wayland text-input-v3 原生協定
                                         # 效能優於舊版 XIM 方式
      addons = with pkgs; [
        fcitx5-chewing                   # 新注音輸入法（libchewing）
        fcitx5-gtk                       # GTK 整合模組
        qt6Packages.fcitx5-qt            # Qt6 整合模組
        qt6Packages.fcitx5-configtool    # 圖形化設定工具
        fcitx5-material-color            # Material Design 主題
      ];
    };
  };

  # ── 輸入法環境變數 ───────────────────────────────────────────────
  #
  # waylandFrontend = true 時：
  #   GTK4 / Qt6 透過 Wayland text-input-v3 協定自動使用 fcitx5
  #   XMODIFIERS 供 XWayland 應用程式使用
  #
  environment.sessionVariables = {
    XMODIFIERS     = "@im=fcitx";
    SDL_IM_MODULE  = "fcitx";
  };

  # ── 首次設定提示 ─────────────────────────────────────────────────
  # 登入後執行 fcitx5-configtool 即可：
  #   1. 確認已新增「新注音」輸入法
  #   2. 設定切換快捷鍵（預設 Ctrl+Space）
  #   3. 若無法啟動 configtool，執行：fcitx5 -d && fcitx5-configtool
}
