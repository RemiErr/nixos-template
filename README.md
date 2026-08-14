# NixOS Template

這是一份採用了以下方案的 Flakes 模板。

- 視窗管理器：[Niri](https://github.com/YaLTeR/niri)（磁磚式 Wayland WM）
- 桌面 Shell：[Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell)
- 終端機：Foot + Fish shell
- 輸入法：fcitx5 + 新注音（Chewing）
- 字型：Maple Mono NF / JetBrainsMono Nerd Font

---

## 使用須知

本 repo 作為 Nix Flake input 被引用，**不需要 clone 本 repo**。

請 clone 該專案：[nixos-config](https://github.com/RemiErr/nixos-config)

```bash
git clone https://github.com/RemiErr/nixos-config.git ~/.config
```

並使用 `~/.config` 目錄作為你的 overlay 起點，其中 `variables.nix` 用於存放系統參數，**請記得先填寫它**。

---

<br>
<br>
<br>

# NixOS 26.05 安裝教學

## 安裝流程預覽

```
[Live 環境]
    │
    ├─ 1. 確認網路 → clone overlay
    │
    ├─ 2. 填寫 variables.nix（username、hostname、git email 等）
    │
    ├─ 3. 磁碟分割 → 格式化 → 掛載至 /mnt
    │
    ├─ 4. nixos-generate-config --root /mnt
    │       └─ cp hardware-configuration.nix → /tmp/my-nixos/
    │
    ├─ 5. sudo nixos-install --flake /tmp/my-nixos#<hostname>
    │
    ├─ 6. sudo nixos-enter → passwd <username> → exit
    │
    └─ 7. sudo reboot（拔除 USB）
```

> [!NOTE]
> **教學由 Claude 生成再編修**，本文是自用的備忘紀錄兼參考範例。  

---

## 目錄

0. [Graphical vs Minimal ISO 差異](#0-graphical-vs-minimal-iso-差異)
1. [前置準備](#1-前置準備)
2. [磁碟與掛載](#2-磁碟與掛載)
3. [硬體識別](#3-硬體識別)
4. [系統建構與安裝](#4-系統建構與安裝)
5. [身分與開機驗證](#5-身分與開機驗證)

---

## 0. Graphical vs Minimal ISO 差異

| 項目          | Graphical ISO                       | Minimal ISO                       |
| ------------- | ----------------------------------- | --------------------------------- |
| 檔案大小      | ~2.4 GB                             | ~900 MB                           |
| Live 環境介面 | GNOME 桌面                          | 純 CLI（TTY）                     |
| 安裝方法      | 提供 GUI 安裝流程，也可以終端機安裝 | 在 TTY 操作                       |
| 內建工具      | 含 GUI 工具                         | 基本工具，需要時用 `nix-shell -p` |

---

## 1. 前置準備

### 1.1 下載 ISO

前往 NixOS 官方下載頁面：`https://nixos.org/download/`

- **Graphical ISO**：選 "NixOS 26.05 → Graphical ISO image"
- **Minimal ISO**：選 "NixOS 26.05 → Minimal ISO image"

### 1.2 製作開機 USB

**Linux / macOS（dd 指令）**：
```bash
# 確認 USB 裝置名稱
lsblk

# 寫入映像（將 /dev/sdX 替換為你的 USB 裝置）
sudo dd if=nixos-26.05-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

**Windows**：使用 [Rufus](https://rufus.ie/) 或 [balenaEtcher](https://etcher.balena.io/)，選擇 DD 模式寫入。

### 1.3 開機進入 Live 環境

1. 插入 USB，重開機，進入 BIOS/UEFI 選擇從 USB 開機
2. 進入 Live 環境後：
   - **Graphical ISO**：在桌面上右鍵 → Open Terminal，或從應用程式選單開啟終端機
   - **Minimal ISO**：直接在 TTY 輸入指令

### 1.4 確認網路連線

```bash
# 確認網路介面
ip addr

# 測試連線
ping -c 3 8.8.8.8
```

若無線網路尚未連線（Graphical ISO 可用 GUI 設定）：
```bash
# 列出可用 Wi-Fi
nmcli device wifi list

# 連線
nmcli device wifi connect "SSID名稱" password "密碼"
```

### 1.5 Clone overlay 並設定 variables.nix

```bash
git clone https://github.com/RemiErr/nixos-config /tmp/my-nixos
cd /tmp/my-nixos
```

若 Live 環境沒有 `git`：
```bash
nix-shell -p git --run "git clone https://github.com/RemiErr/nixos-config /tmp/my-nixos"
cd /tmp/my-nixos
```

**填寫 `variables.nix`**：

```bash
nano variables.nix
```

```nix
{
  username        = "alice";              # 你的使用者名稱
  hostname        = "my-machine";         # 主機名稱
  homeDirectory   = "/home/alice";        # 家目錄
  userDescription = "Alice";              # 顯示名稱

  git = {
    name  = "Alice";
    email = "alice@example.com";
  };
}
```

> [!NOTE]
> `hardware-configuration.nix` 在步驟 3 產生後補入，現在先跳過。

---

## 2. 磁碟與掛載

### 2.1 Linux 磁碟結構說明

NixOS 使用 UEFI 開機，需要以下三個分割區：

| 分割區 | 格式  | 掛載點   | 作用                 | 建議大小                        |
| ------ | ----- | -------- | -------------------- | ------------------------------- |
| sda1   | FAT32 | `/boot`  | EFI System Partition | 512 MB ~ 1 GB                   |
| sda2   | swap  | `[swap]` | 虛擬記憶體           | 等於 RAM（支援休眠）；最少 4 GB |
| sda3   | ext4  | `/`      | 根目錄               | 剩餘全部（建議 ≥ 30 GB）        |

### 2.2 確認目標磁碟

> [!CAUTION]
> ⚠️ **警告**：之後的操作會清除磁碟上的 *所有資料*，操作前請再三確認磁碟名稱。

```bash
lsblk
```

輸出範例（`sda` 是目標磁碟，`sdb` 是 USB 開機碟）：
```
NAME   SIZE TYPE MOUNTPOINT
sda    256G disk              ← 目標安裝磁碟
sdb     16G disk              ← USB 開機碟
└─sdb1  16G part /run/media/...
```

以下步驟以 `/dev/sda` 為例，請依實際情況替換。

### 2.3 建立分割區

```bash
# 建立 GPT 分割表（清除現有分割資訊）
sudo parted -s /dev/sda mklabel gpt

# EFI 分割區：1MB ~ 513MB = 512MB
sudo parted -s /dev/sda mkpart ESP fat32 1MB 513MB
sudo parted -s /dev/sda set 1 esp on

# Swap 分割區：513MB ~ 4.5GB = 4GB（依你的 RAM 調整）
sudo parted -s /dev/sda mkpart primary linux-swap 513MB 4.5GB

# Root 分割區：剩餘全部空間
sudo parted -s /dev/sda mkpart primary ext4 4.5GB 100%

# 確認結果
sudo parted /dev/sda print
lsblk /dev/sda
```

預期結構：
```
NAME   SIZE TYPE
sda    256G disk
├─sda1 512M part   ← EFI
├─sda2   4G part   ← swap
└─sda3 251G part   ← root
```

### 2.4 格式化分割區

```bash
# EFI：FAT32 格式，標籤 "boot"
sudo mkfs.fat -F 32 -n boot /dev/sda1

# Swap：建立 swap 空間，標籤 "swap"
sudo mkswap -L swap /dev/sda2

# 啟用 swap（讓系統在安裝期間也可使用）
sudo swapon /dev/sda2

# Root：ext4 格式，標籤 "nixos"
sudo mkfs.ext4 -L nixos /dev/sda3
```

### 2.5 掛載分割區

```bash
# 掛載 root
sudo mount /dev/disk/by-label/nixos /mnt

# 建立並掛載 boot（umask=077 確保只有 root 可讀）
sudo mkdir -p /mnt/boot
sudo mount -o umask=077 /dev/disk/by-label/boot /mnt/boot

# 確認掛載
lsblk /dev/sda
# sda3 應顯示 /mnt，sda1 應顯示 /mnt/boot
```

---

## 3. 硬體識別

**時機**：`/mnt` 掛載完成後，`nixos-install` 之前  
**位置**：Live 環境終端機  
**身分**：一般使用者（加 `sudo`）

```bash
sudo nixos-generate-config --root /mnt
```

此指令會自動偵測這台機器的硬體（CPU、GPU、磁碟 UUID、掛載點等），並在 `/mnt/etc/nixos/` 產生兩個檔案：
- `hardware-configuration.nix`：機器專屬硬體設定（重要）
- `configuration.nix`：預設系統設定（本教學不使用此檔案）

**將硬體設定複製進 overlay**：

```bash
cp /mnt/etc/nixos/hardware-configuration.nix \
   /tmp/my-nixos/hardware-configuration.nix
```

確認內容正確（應包含你的磁碟 UUID）：
```bash
cat /tmp/my-nixos/hardware-configuration.nix
# 查看是否有 fileSystems."/" 和 fileSystems."/boot"
```

**讓 Nix 看到這個檔案**：

Nix flake 只讀取 git 追蹤的檔案。`hardware-configuration.nix` 已在 `.gitignore` 中排除（機器專屬、不應提交），因此需要手動 stage：

```bash
cd /tmp/my-nixos
git add -f hardware-configuration.nix
```

> [!IMPORTANT]  
> 不需要 `git commit`，`git add` 後 Nix 即可讀取。日後在已安裝的系統上重新執行 `nixos-rebuild` 時，同樣需要確保這個檔案已被 stage。  

> [!CAUTION]
> ⚠️ **注意**：`hardware-configuration.nix` 每台機器都不同，***絕對不可以*** 複製他人的檔案來使用！！

---

## 4. 系統建構與安裝

### 4.1 啟用 Flakes（Live 環境）

NixOS 26.05 的 ISO 通常已支援 Flakes。若出現：
```
error: experimental Nix feature 'flakes' is disabled
```

執行：
```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
```

你可以手動驗證：
```bash
nix show-config | grep experimental-features

# 輸出若包含 nix-command 和 flakes 就代表已啟用：
# experimental-features = nix-command flakes
```

### 4.2 nixos-install 指令

**時機**：`hardware-configuration.nix` 已複製進 repo 後  
**位置**：Live 環境終端機  
**身分**：root（sudo）

```bash
cd /tmp/my-nixos
sudo nixos-install \
  --flake .#<hostname> \
  --no-root-password
```

將 `<hostname>` 替換為你在 `variables.nix` 中填入的 `hostname` 值。

安裝過程約需 10–60 分鐘（可能更久），出現 `installation finished!` 表示成功。

### 4.3 設定使用者密碼

**時機**：`nixos-install` 完成後，重開機之前  
**位置**：Live 環境終端機  
**身分**：root（sudo）

安裝完成後，在重開機之前設定 `user` 的登入密碼：
```bash
# 進入已安裝的系統環境
sudo nixos-enter --root /mnt

# 設定使用者密碼
passwd <username>
# 輸入密碼（不會顯示字元），確認後再輸入一次

# 離開 chroot 環境
exit
```

---

## 5. 身分與開機驗證

### 5.1 重新開機

```bash
sudo reboot
```

重開機時拔除 USB 開機碟，確保從硬碟開機。

### 5.2 首次開機驗證

```bash
hostnamectl          # 確認 hostname

whoami               # 確認使用者

nix --version        # 確認 Nix 可用

git --version        # 確認 git

ip addr              # 確認網路介面

sudo systemctl status NetworkManager

sudo echo "sudo OK"
```

### 5.3 日常維護

首次開機後，將 overlay 放到你慣用的位置（例如 `~/.config`）：

```bash
cp -r /tmp/my-nixos ~/.config
cd ~/.config
```

**套用系統設定**：
```bash
update ~/.config # 等同 sudo nixos-rebuild switch --flake ~/.config#<hostname>
```
或
```bash
cd ~/.config
update           # 等同 sudo nixos-rebuild switch --flake .#<hostname>
```
> [!IMPORTANT]
> 如果你有覆蓋 Template 設定的需求，可以 Clone/Fork：[nixos-template](https://github.com/RemiErr/nixos-template)，將 Template 指向新的位置，並於修改後進行測試。  
> `update ~/.config --override-input nixos-template path:~/<YOUR-LOCAL-PATH>/nixos-template`

**套用 Home Manager 設定**：
```bash
hm ~/.config  # 等同 home-manager switch --flake ~/.config#<username>@<hostname>
```
或
```bash
cd ~/.config
hm            # 等同 home-manager switch --flake .#<username>@<hostname>
```

**更新 template（拉取本 repo 的最新版本）**：
```bash
cd ~/.config
nix flake update nixos-template
update
```

**清理舊世代**：
```bash
gc
```

### 5.4 設定 SSH 金鑰（選用）

本設定已啟用 SSH 服務，但停用密碼登入（僅允許金鑰認證）。若需要從遠端連入：

```bash
# 在目標機器上，建立 authorized_keys
mkdir -p ~/.ssh
chmod 700 ~/.ssh
# 將你的公鑰貼入
echo "ssh-ed25519 AAAA... your@machine" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```
