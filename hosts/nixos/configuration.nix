{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix          # nixos-generate-config 自動生成
    ../../modules/system/common.nix       # 基本設定、Flakes、時區
    ../../modules/system/wayland.nix      # Wayland、音訊、字型、登入管理器
    ../../modules/system/input-method.nix # fcitx5 + 注音
    ../../modules/system/users.nix        # 使用者帳號
  ];

  # 主機名稱
  networking.hostName = "nixos";

  # 允許安裝 unfree 套件（如 NVIDIA 驅動等）
  nixpkgs.config.allowUnfree = true;

  # !! 必須與 home.stateVersion 一致，初次設定後不可修改 !!
  system.stateVersion = "25.11";
}
