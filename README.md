# NixOS 25.11 安裝教學

> **教學由 Claude 生成再編修**，本文是自用的參考範例。  
> 
```bash
#【系統設定】  
# 使用 Niri + Wayland
# 不安裝 KDE/GNOME 等桌面環境
username = user #（請替換為你的帳號名稱）
hostname = nixos
```

---

## 安裝流程預覽

```
[Live 環境]
    │
    ├─ 1. 確認網路、clone repo
    │
    ├─ 2. 磁碟分割（parted）→ 格式化 → 掛載至 /mnt
    │
    ├─ 3. nixos-generate-config --root /mnt
    │       └─ cp hardware-configuration.nix → /tmp/nixos-config/hosts/nixos/
    │
    ├─ 4. sudo nixos-install --flake /tmp/nixos-config#nixos --no-root-password
    │       └─（等待 10~60 分鐘）
    │
    ├─ 5. sudo nixos-enter --root /mnt → passwd user → exit
    │
    └─ 6. sudo reboot（拔除 USB）

[首次開機]
    └─ 登入 user → 執行驗證清單
```

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

- **Graphical ISO**：選 "NixOS 25.11 → Graphical ISO image"
- **Minimal ISO**：選 "NixOS 25.11 → Minimal ISO image"

### 1.2 製作開機 USB

**Linux / macOS（dd 指令）**：
```bash
# 確認 USB 裝置名稱
lsblk

# 寫入映像（將 /dev/sdX 替換為你的 USB 裝置）
sudo dd if=nixos-25.11-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
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

### 1.5 Clone repo 並確認設定

Clone 後，將以下三個檔案中的 `user` 替換為你的實際帳號名稱、`Your Name` / `your@email.com` 替換為你的 Git 資訊：
- `flake.nix`：`home-manager.users.user`、`"user@nixos"`
- `home/default.nix`：`home.username`、`home.homeDirectory`、`userName`、`userEmail`
- `modules/system/users.nix`：`users.users.user`

```bash
# 在 Live 環境，以一般指令方式 clone（不需 sudo）
git clone https://github.com/<你的帳號>/nixos-config.git /tmp/nixos-config

# 確認主機設定存在
ls /tmp/nixos-config/hosts/nixos/
# 應看到 configuration.nix（hardware-configuration.nix 之後補入）
```

若 Live 環境沒有 `git`：
```bash
nix-shell -p git --run "git clone https://github.com/<你的帳號>/nixos-config.git /tmp/nixos-config"
```

---

## 2. 磁碟與掛載

### 2.1 Linux 磁碟結構說明

NixOS 使用 UEFI 開機，需要以下三個分割區：

| 分割區 | 格式  | 掛載點   | 作用                                        | 建議大小                             |
| ------ | ----- | -------- | ------------------------------------------- | ------------------------------------ |
| sda1   | FAT32 | `/boot`  | EFI System Partition，UEFI 韌體讀取開機程式 | 512 MB ~ 1 GB                        |
| sda2   | swap  | `[swap]` | 虛擬記憶體，系統記憶體不足時使用            | 等於 RAM 大小（支援休眠）；最少 4 GB |
| sda3   | ext4  | `/`      | 根目錄，系統本體與所有資料                  | 剩餘全部空間（建議 ≥ 30 GB）         |

**為什麼需要 EFI 分割區？**  
現代 UEFI 韌體只能直接讀取 FAT32 格式的分割區來**載入開機程式（systemd-boot）**。沒有這個分割區，系統無法開機。

**為什麼需要 Swap？**  
Linux 運作時可能消耗大量記憶體（如：NixOS 編譯套件），Swap 可以硬碟空間提供緩衝。  
若需要休眠（Hibernate）功能，Swap 大小必須 ≥ 實體 RAM。

### 2.2 確認目標磁碟

> ⚠️ **警告**：以下操作會清除磁碟上的所有資料，操作前請再三確認磁碟名稱。

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
sudo parted /dev/sda -- mklabel gpt

# EFI 分割區：1MB ~ 513MB = 512MB
sudo parted /dev/sda -- mkpart ESP fat32 1MB 513MB
sudo parted /dev/sda -- set 1 esp on

# Swap 分割區：513MB ~ 4.5GB = 4GB（依你的 RAM 調整）
sudo parted /dev/sda -- mkpart primary linux-swap 513MB 8.5GB

# Root 分割區：剩餘全部空間
sudo parted /dev/sda -- mkpart primary ext4 8.5GB 100%

# 確認結果
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

**將硬體設定複製進 repo**（最關鍵步驟）：

```bash
cp /mnt/etc/nixos/hardware-configuration.nix \
   /tmp/nixos-config/hosts/nixos/hardware-configuration.nix
```

確認內容正確（應包含你的磁碟 UUID）：
```bash
cat /tmp/nixos-config/hosts/nixos/hardware-configuration.nix
# 查看是否有 fileSystems."/" 和 fileSystems."/boot"
```

> ⚠️ **注意**：`hardware-configuration.nix` 每台機器都不同，***絕對不可以*** 複製他人的檔案來使用！！

---

## 4. 系統建構與安裝

### 4.1 Flakes 在 Live 環境的啟用方式

**系統安裝完成後**：Flakes 已由 `modules/system/common.nix` 自動啟用，無需任何額外操作。

**在 Live 環境執行 `nixos-install` 之前**：NixOS 25.11 的 ISO 通常已支援 `nix` 指令與 Flakes。

若執行時出現以下錯誤：

```
error: experimental Nix feature 'flakes' is disabled
```

執行以下指令啟用（僅對目前的 Live 環境工作階段有效）：
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
sudo nixos-install \
  --flake /tmp/nixos-config#nixos \
  --no-root-password
```

**指令格式說明**：

| 參數                   | 說明                                                                    |
| ---------------------- | ----------------------------------------------------------------------- |
| `--flake <路徑>#<key>` | `#` 後的 `nixos` 對應 `flake.nix` 中 `nixosConfigurations.nixos` 的鍵名 |
| `--no-root-password`   | 不設定 root 密碼（本設定使用 wheel 群組 + sudo 取代 root 登入）         |

> 安裝過程中會下載並建構整個系統，時間視網路速度與硬體而定（約 10–60 分鐘）。

出現以下訊息表示成功：

```
installation finished!
```

若出現 `nix: command not found`，請先執行 `nix-shell -p nix` 或確認 `/nix/store` 已掛載。

### 4.3 設定使用者密碼

**時機**：`nixos-install` 完成後，重開機之前  
**位置**：Live 環境終端機  
**身分**：root（sudo）

安裝完成後，在重開機之前設定 `user` 的登入密碼：
```bash
# 進入已安裝的系統環境
sudo nixos-enter --root /mnt

# 設定使用者密碼
passwd user
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

### 5.2 首次開機流程

1. **systemd-boot 選單**：出現開機選單，選第一個項目（最新世代）
2. **登入提示**：
   ```
   nixos login: user
   Password:
   ```
   輸入你設定的用戶密碼
3. **預期畫面**：出現 Bash 提示符（純 CLI）

```
[user@nixos:~]$
```

> 本設定不含桌面環境。

### 5.3 首次開機驗證清單

逐一執行以下指令確認系統狀態：

```bash
# 確認 hostname
hostnamectl
# 應顯示：Static hostname: nixos

# 確認使用者
whoami
# 應顯示：user

# 確認 Flakes 可用
nix --version
# 應顯示：nix (Nix) 2.x.x

# 確認 git
git --version
# 應顯示：git version 2.x.x

# 確認網路
ip addr
# 應看到網路介面（eth0 或 enp... 或 wlan0）

# 確認 NetworkManager 服務
sudo systemctl status NetworkManager
# 應顯示 active (running)

# 確認 sudo 可用
sudo echo "sudo OK"
# 應顯示：sudo OK
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

### 5.5 日常維護指令

```bash
# 套用系統設定變更
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
# 或使用別名：
update

# 套用 Home Manager 設定變更
home-manager switch --flake ~/nixos-config#user@nixos
# 或使用別名：
hm

# 更新所有套件（更新 flake.lock）
cd ~/nixos-config && nix flake update
sudo nixos-rebuild switch --flake .#nixos

# 清理舊世代
sudo nix-collect-garbage -d
# 或使用別名：
gc

# 查詢現有世代
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
# 或使用別名：
gens
```