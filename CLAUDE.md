# CLAUDE.md

## 架構概覽

本 repo 是純 module provider，不包含可獨立建置的主機設定。外部 flake 負責：

- 宣告 `nixpkgs`、Home Manager、Noctalia 等 inputs
- 建立 `nixosConfigurations`
- 提供硬體設定與 `system.stateVersion`
- 透過 `specialArgs` / `extraSpecialArgs` 傳入 `vars` 與 `inputs`

本 repo 只輸出：

- `nixosModules.default`：彙整 `modules/system/`
- `homeModules.default`：匯出 `home/default.nix`

## 目錄結構

```text
flake.nix              # module exports
modules/system/
  common.nix           # Nix、開機、locale、基礎套件
  wayland.nix          # Niri、portal、PipeWire、greetd、字型
  input-method.nix     # fcitx5 + Chewing
  users.nix            # 使用者與 NetworkManager
modules/home/
  niri.nix             # Niri 與 swayidle
  fish.nix             # Fish shell
  foot.nix             # Foot 終端機
  fastfetch.nix        # 系統資訊
  *.nix                # 可選桌面元件
home/default.nix       # Home Manager 聚合入口與 Noctalia 設定
```

## 外部整合介面

System modules 需要外部提供 `vars.username` 與 `vars.userDescription`。Home module 另需要完整的 `vars`，以及包含 `noctalia` 的 `inputs`：

```nix
specialArgs = { inherit inputs vars; };
home-manager.extraSpecialArgs = { inherit inputs vars; };
```

實際版本、個人變數、硬體與建置指令由 `nixos-config` consumer 管理。修改 module interface 時，必須同步更新 consumer。
