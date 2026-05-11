# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 常用指令

```bash
# 重建系統設定（hostname 由 variables.nix 決定）
sudo nixos-rebuild switch --flake ~/nixos-config#<hostname>

# 更新所有 flake inputs
nix flake update

# 垃圾回收（清除所有舊世代）
nix-collect-garbage -d
```

## 架構概覽

這是一個基於 **NixOS Flakes** 的模組化設定，使用 **Niri**（磁磚式 Wayland 視窗管理器）並支援繁體中文輸入（fcitx5 + 注音）。

設計為**可被外部 flake 引用的模板**：使用者不需 clone 本 repo，透過 `inputs.nixos-template.url = "github:RemiErr/nixos-template"` 引用後，只需維護自己的 `variables.nix` 即可。

### 目錄結構

```
flake.nix              # 入口：exports nixosModules.default / homeModules.default
variables.nix          # 個人值（gitignored，從 variables.nix.example 複製）
variables.nix.example  # 範本，committed，含所有需填入的 placeholder
.config/               # nixos-config repo 的本地草稿（不 commit 進本 repo）
                       # 內容對應 github:RemiErr/nixos-config（使用者的 overlay 起點）
hosts/nixos/           # 主機層設定（hostname 由 vars 注入）
modules/system/        # NixOS 系統模組
  common.nix           # Nix 設定、時區(Asia/Taipei)、locale、基礎套件
  wayland.nix          # Niri、XDG portal、PipeWire、greetd、字型
  input-method.nix     # fcitx5 + Chewing 注音輸入法
  users.nix            # 使用者帳號、NetworkManager
modules/home/          # Home Manager 模組（每個元件獨立一檔）
  niri.nix             # 視窗管理器設定 + 快捷鍵（KDL 格式）
  foot.nix             # 終端機（foot）
  fish.nix             # Shell（fish）
  fuzzel.nix           # 應用程式啟動器
  hyprlock.nix         # 鎖定畫面
  fastfetch.nix        # 系統資訊
home/default.nix       # Home Manager 入口，彙整所有 home 模組
```

### variables.nix 設計

所有使用者相關的個人值集中在 `variables.nix`（gitignored），透過 `specialArgs` / `extraSpecialArgs` 傳入所有模組：

```nix
{
  username        = "shiichi";
  hostname        = "my-machine";
  homeDirectory   = "/home/shiichi";
  userDescription = "Shiichi";
  git = {
    name  = "RemiErr";
    email = "re.err236@gmail.com";
  };
}
```

各模組透過函式參數 `{ vars, ... }:` 接收這些值，不再有任何硬編碼的 `# CHANGE:` 位置。

### Flake 設計

- **nixpkgs**：`nixos-25.11`
- **home-manager**：`release-25.11`
- **module exports**：`nixosModules.default`（系統模組）、`homeModules.default`（home 模組）
- `vars` 從 `variables.nix` import，透過 `specialArgs` / `extraSpecialArgs` 傳入所有模組

### 模組整合方式

`hosts/nixos/configuration.nix` 匯入全部 `modules/system/` 模組；`home/default.nix` 匯入全部 `modules/home/` 模組。Home Manager 透過 `home-manager.nixosModules.home-manager` 整合進系統設定。

### 客製化重點（維護者）

1. 複製 `variables.nix.example` → `variables.nix`，填入真實值
2. 將 `variables.nix` 加入 `.gitignore`
3. `hosts/nixos/hardware-configuration.nix` 使用 `nixos-generate-config` 為每台機器重新生成
