{ pkgs, ... }:

{
  # Steam 會自動啟用 32-bit 圖形與音訊支援，並安裝控制器 udev rules。
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];

    # 預設不為 Steam 遠端功能開啟入站防火牆連接埠。
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    localNetworkGameTransfers.openFirewall = false;
  };

  # 可在 Steam 啟動選項使用：gamescope -f -- %command%
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # 可在 Steam 啟動選項使用：gamemoderun %command%
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud      # 幀率、幀時間與 GPU/CPU overlay
    vulkan-tools  # vulkaninfo、vkcube
    mesa-demos    # glxinfo、glxgears
  ];
}
