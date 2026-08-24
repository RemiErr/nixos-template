# CLAUDE.md

## 架構概覽

本 repo 是純 module provider，不包含可獨立建置的主機設定。外部 flake 負責：

- 宣告 `nixpkgs`、Home Manager 等 inputs
- 建立 `nixosConfigurations`
- 提供硬體設定與 `system.stateVersion`
- 透過 `specialArgs` / `extraSpecialArgs` 傳入 `vars` 與 `inputs`

本 repo 只輸出：

- `nixosModules.default`：彙整 `modules/system/`
- `homeModules.default`：匯出 `home.nix`

## 目前桌面配置

- 預設桌面環境是 KDE Plasma 6，使用 Wayland session。
- 登入管理器是 SDDM，登入畫面使用 Wayland，`defaultSession = "plasma"`。
- KDE 預設應用程式由 `home.nix` 設為 Dolphin、Ark、Okular、Kate 與 Gwenview。
- Niri、Noctalia 與 Foot 的設定仍保留在 repo 中，但目前停用，方便日後切換或復用。

## 目錄結構

```text
flake.nix              # module exports
modules/system/
  common.nix           # Nix、開機、locale、基礎套件
  wayland.nix          # Plasma 6、SDDM Wayland、PipeWire、字型
  input-method.nix     # fcitx5 + Chewing
  users.nix            # 使用者與 NetworkManager
  gaming.nix           # Steam、Gamescope、GameMode
modules/home/
  niri.nix             # 可選：Niri、swayidle 與快捷鍵
  noctalia.nix         # 可選：Noctalia Shell 設定
  fish.nix             # Fish shell
  foot.nix             # 可選：Foot 終端機
  fastfetch.nix        # 系統資訊
home.nix               # Home Manager 聚合入口、模組開關與 KDE 預設應用程式
```

## 外部整合介面

System modules 需要外部提供 `vars.username` 與 `vars.userDescription`。Home module 目前需要完整的 `vars`；consumer 仍透過 `inputs` 保留擴充介面：

```nix
specialArgs = { inherit inputs vars; };
home-manager.extraSpecialArgs = { inherit inputs vars; };
```

若要重新啟用 Noctalia，除了在 `home.nix` 匯入
`inputs.noctalia.homeModules.default` 與 `modules/home/noctalia.nix`，也必須：

- 將 `inputs` 加回 `home.nix` 的函式參數。
- 在 consumer `nixos-config/flake.nix` 恢復 `noctalia` 及其所需的 nixpkgs input。
- 同步啟用 `modules/home/niri.nix` 與對應的 Niri system 設定。

## 維護原則

- 切換預設桌面環境優先保留既有模組，以停用選項或註解 import 的方式切換。
- KDE 與 Niri 的登入管理器不可同時啟用；KDE 使用 SDDM，Niri 使用 greetd。
- 桌面專屬的 Home Manager 模組應由 `home.nix` 集中控制是否匯入，避免停用桌面後仍啟動其 user service。
- Plasma 6 會自行提供 KDE portal、KWallet、udisks2、XWayland 與主要 KDE 應用程式；調整 Niri 專屬服務時，不要覆蓋 Plasma 共用依賴。
- 修改 module interface、flake input 或桌面切換流程時，必須同步更新 consumer 與本文件。

實際版本、個人變數、硬體與建置指令由 `nixos-config` consumer 管理。
