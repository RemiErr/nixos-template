{ config, pkgs, lib, ... }:

{
  # ── 使用者帳號 ───────────────────────────────────────────────────
  # CHANGE: replace every "user" with your username (must match flake.nix and home/default.nix)
  users.users.user = {          # CHANGE: replace "user" with your username
    isNormalUser = true;
    description  = "User";      # CHANGE: replace "User" with your display name
    extraGroups  = [
      "wheel"           # sudo 權限
      "networkmanager"  # 網路設定
      "video"           # 螢幕亮度（brightnessctl）
      "audio"           # 音訊裝置
      "input"           # 輸入裝置（滑鼠/鍵盤事件）
      "seat"            # seatd（部分 Wayland 環境需要）
      "vboxsf"          # VirtualBox 共享資料夾
    ];
    shell = pkgs.bash;
    # 密碼在首次登入後設定：sudo passwd user
    # 或在安裝時設定：nixos-install 完成後執行 passwd user
  };

  # ── 禁止 root 登入（安全）───────────────────────────────────────
  users.users.root.hashedPassword = "!";  # 鎖定 root 密碼

  # ── sudo 設定 ────────────────────────────────────────────────────
  security.sudo = {
    enable             = true;
    wheelNeedsPassword = true;   # wheel 群組執行 sudo 需輸入密碼
  };

  # ── 網路管理 ────────────────────────────────────────────────────
  networking.networkmanager = {
    enable = true;
    # DNS 可選：
    # dns = "systemd-resolved";
  };

  # ── 藍牙（選用，取消注解即可啟用）──────────────────────────────
  # hardware.bluetooth = {
  #   enable      = true;
  #   powerOnBoot = true;
  # };
  # services.blueman.enable = true;
}
