# ╔══════════════════════════════════════════════════════════════╗
# ║  此檔案由 nixos-generate-config 自動生成，請勿手動填寫       ║
# ║                                                              ║
# ║  安裝流程：                                                  ║
# ║    1. 完成磁碟分割後執行：                                   ║
# ║       nixos-generate-config --root /mnt                      ║
# ║    2. 將生成的檔案複製到此處：                               ║
# ║       cp /mnt/etc/nixos/hardware-configuration.nix \         ║
# ║          ./hosts/nixos/hardware-configuration.nix            ║
# ║    3. 確認內容正確後提交至 Git                               ║
# ╚══════════════════════════════════════════════════════════════╝
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ── 以下為範例佔位，實際值由 nixos-generate-config 生成 ────────

  boot.initrd.availableKernelModules = [
    "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # 磁碟掛載點（由 nixos-generate-config 生成的 by-uuid 或 by-label）
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
