# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 常用指令

```bash
# 重建系統設定
sudo nixos-rebuild switch --flake ~/nixos-config#nixos

# 重建 Home Manager 設定（需替換為實際使用者名稱）
home-manager switch --flake ~/nixos-config#user@nixos

# 更新所有 flake inputs
nix flake update

# 垃圾回收（清除所有舊世代）
nix-collect-garbage -d
```

## 架構概覽

這是一個基於 **NixOS Flakes** 的模組化設定，使用 **Niri**（磁磚式 Wayland 視窗管理器）並支援繁體中文輸入（fcitx5 + 注音）。

### 目錄結構

```
flake.nix              # 入口：inputs/outputs，宣告所有 nixpkgs 版本與主機
hosts/nixos/           # 主機層設定（hostname、hardware-configuration.nix）
modules/system/        # NixOS 系統模組
  common.nix           # Nix 設定、時區(Asia/Taipei)、locale、基礎套件
  wayland.nix          # Niri、XDG portal、PipeWire、greetd、字型
  input-method.nix     # fcitx5 + Chewing 注音輸入法
  users.nix            # 使用者帳號、NetworkManager
modules/home/          # Home Manager 模組（每個元件獨立一檔）
  niri.nix             # 視窗管理器設定 + 快捷鍵（KDL 格式）
  waybar.nix           # 狀態列（Catppuccin Mocha 主題）
  kitty.nix            # 終端機
  fuzzel.nix           # 應用程式啟動器
  mako.nix             # 桌面通知
  swww.nix             # 桌布管理（systemd user service）
  wlogout.nix          # 登出選單
  hyprlock.nix         # 鎖定畫面
home/default.nix       # Home Manager 入口，彙整所有 home 模組
```

### Flake 設計

- **nixpkgs**：`nixos-25.11`
- **home-manager**：`release-25.11`
- 主機設定 `"nixos"`，使用者設定 `"user@nixos"`
- 若要新增主機，在 `flake.nix` 的 `nixosConfigurations` 與 `homeConfigurations` 各加一條，並在 `hosts/` 下建對應目錄

### 模組整合方式

`hosts/nixos/configuration.nix` 匯入全部 `modules/system/` 模組；`home/default.nix` 匯入全部 `modules/home/` 模組。Home Manager 透過 `nixosModules.homeManager` 整合進系統設定，不需要獨立執行。

### 主題與視覺一致性

所有使用者介面元件（waybar、kitty、fuzzel、mako、wlogout、hyprlock）統一使用 **Catppuccin Mocha** 調色盤，修改顏色時應保持全局一致。

### 客製化重點

三個需在新機器上修改的關鍵位置：
1. `flake.nix`：主機名稱與使用者名稱
2. `home/default.nix`：`home.username` / `home.homeDirectory`
3. `modules/system/users.nix`：使用者帳號定義

`hosts/nixos/hardware-configuration.nix` 應使用 `nixos-generate-config` 為每台機器重新生成，不應手動複製。
