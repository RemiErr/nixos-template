{ pkgs, vars, ... }:

{
  imports = [
    ./hardware-configuration.nix          # nixos-generate-config 自動生成
    ../../modules/system/common.nix       # 基本設定、Flakes、時區
    ../../modules/system/wayland.nix      # Wayland、音訊、字型、登入管理器
    ../../modules/system/input-method.nix # fcitx5 + 注音
    ../../modules/system/users.nix        # 使用者帳號
  ];

  networking.hostName = vars.hostname;

  # 允許安裝 unfree 套件（如 NVIDIA 驅動等）
  nixpkgs.config.allowUnfree = true;

  # ── VirtualBox Guest Additions ──────────────────────────────────
  virtualisation.virtualbox.guest = {
    enable      = true;
    dragAndDrop = false;  # 避免 DragAndDrop 服務在 Wayland 下無限重啟
  };

  # !! 必須與 home.stateVersion 一致，初次設定後不可修改 !!
  system.stateVersion = "26.05";
}
