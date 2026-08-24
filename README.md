# NixOS Template

這是一份採用了以下方案的 Flakes 模板。

- 桌面環境：[KDE Plasma 6](https://kde.org/plasma-desktop/)（預設 Wayland session）
- 登入管理器：SDDM（Wayland）
- 終端機：Konsole / Foot + Fish shell
- 輸入法：fcitx5 + 新注音（Chewing）
- 字型：Maple Mono NF / JetBrainsMono Nerd Font
- 開發環境：可選的 Python + AMD ROCm AI dev shell

---

## 使用須知

本 repo 作為 Nix Flake input 被引用，**不需要 clone 本 repo**。

請 clone 該專案：[nixos-config](https://github.com/RemiErr/nixos-config)

```bash
git clone --branch dev/kde-plasma https://github.com/RemiErr/nixos-config.git ~/.config/nixfiles
```

並使用 `~/.config/nixfiles` 目錄作為你的 overlay 起點，其中 `variables.nix` 用於存放系統參數，**請記得先填寫它**。

### AMD ROCm AI dev shell（選用）

consumer 可沿用自己的 nixpkgs，呼叫 template 提供的 shell factory：

```nix
devShells.${system}.ai =
  nixos-template.lib.mkAmdAiShell { inherit pkgs; };
```

進入環境：

```bash
nix develop .#ai
```

主機使用者仍需具備 `video` 與 `render` 群組權限；GPU 型號專屬的
`HSA_OVERRIDE_GFX_VERSION` 等 workaround 不由 template 預設。

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
    │       └─ cp hardware-configuration.nix → ~/.config/nixfiles/
    │
    ├─ 5. sudo nixos-install --flake ~/.config/nixfiles#<hostname>
    │
    ├─ 6. sudo nixos-enter → passwd <username> → exit
    │
    └─ 7. sudo reboot（拔除 USB）
```

## 最終載入結構
```
~/.config/nixfiles/flake.nix
│
├─ variables.nix                      個人與主機參數
├─ hardware-configuration.nix         機器硬體設定
│
├─ nixos-template.lib.mkAmdAiShell
│  └─ devshells/amd-ai.nix             Python + AMD ROCm AI dev shell
│
├─ nixos-template.nixosModules.default
│  ├─ common.nix                      Nix、開機、locale、SSH、基礎工具
│  ├─ wayland.nix                     Plasma 6、SDDM、PipeWire、字型
│  ├─ input-method.nix                Fcitx5 + Chewing
│  ├─ users.nix                       使用者、sudo、NetworkManager
│  └─ gaming.nix                      Steam、Gamescope、GameMode
│
└─ Home Manager
   └─ nixos-template.homeModules.default
      ├─ fish.nix
      ├─ foot.nix
      └─ fastfetch.nix
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
git clone --branch dev/kde-plasma https://github.com/RemiErr/nixos-config ~/.config/nixfiles
cd ~/.config/nixfiles
```

若 Live 環境沒有 `git`，請先執行：
```bash
nix-shell -p git
```

**填寫 `variables.nix`**：

```bash
cp variables.nix.example variables.nix
nano variables.nix
```

```nix
{
  username        = "alice";              # 你的使用者名稱
  hostname        = "my-machine";         # 主機名稱
  homeDirectory   = "/home/alice";        # 家目錄
  userDescription = "Alice";              # 顯示名稱
  editor          = "vim";                # 預設編輯器

  git = {
    name  = "Alice";
    email = "alice@example.com";
  };

  stateVersion = "26.05";
}
```

`variables.nix` 已被 `.gitignore` 排除，但 Flake 仍必須從 Git index
讀取它。編輯完成後將檔案加入 index，不需要 commit：

```bash
git add -f variables.nix
```

> [!NOTE]
> `hardware-configuration.nix` 在步驟 3 產生後補入，現在先跳過。

---

## 2. 磁碟與掛載


本篇預設 NixOS 使用 UEFI 開機，提供以下兩種結構的配置流程：
- 方案一：[esp + swap + ext4](#21-linux-磁碟結構說明)
- 方案二：[esp + btrfs](#22-linux-磁碟結構說明--btrfs)

### 2.1 Linux 磁碟結構說明

ext4 基礎配置需要以下三個分割區：

| 分割區 | 格式  | 掛載點   | 作用                 | 建議大小                        |
| ------ | ----- | -------- | -------------------- | ------------------------------- |
| sda1   | FAT32 | `/boot`  | EFI System Partition | 512 MB ~ 1 GB                   |
| sda2   | swap  | `[swap]` | 虛擬記憶體           | 等於 RAM（支援休眠）；最少 4 GB |
| sda3   | ext4  | `/`      | 根目錄               | 剩餘全部（建議 ≥ 30 GB）        |

> [!IMPORTANT]
> 範例採用 `/dev/sda`，若你的硬碟裝置名稱不同，請將所有 `/dev/sda` 替換成實際裝置。

### 2.1.1 確認目標磁碟

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

### 2.1.2 建立分割區

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

### 2.1.3 格式化分割區

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

### 2.1.4 掛載分割區

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

### 2.2 Linux 磁碟結構說明 — Btrfs

Btrfs 是支援 Copy-on-Write、checksum、透明壓縮、快照及子卷的檔案系統。
「子卷（subvolume）」看起來像目錄，但可以獨立掛載及建立快照；各子卷共用同一個 Btrfs partition 的可用空間，不需要預先分配固定容量。

本篇以這三個基本子卷為例：

| 子卷    | 掛載點  | 用途                                        |
| ------- | ------- | ------------------------------------------- |
| `@`     | `/`     | 系統根目錄                                  |
| `@home` | `/home` | 使用者資料，與系統根目錄分開管理            |
| `@swap` | `/swap` | 放置 Btrfs swapfile，避免被一般系統快照包含 |

> [!IMPORTANT]
> 範例採用 `/dev/sda`，若你的硬碟裝置名稱不同，請將所有 `/dev/sda` 替換成實際裝置。

> [!NOTE]
> 前文建立的 swap 分割區與 `@swap/swapfile` 是兩種 swap 方案。
> 建議只使用其中一種，以免容量規劃及休眠設定混淆了。
> 以下示範 Btrfs swapfile，因此不需要建立前文的 `swap` 分割區。

#### 2.2.1 建立分割區

在這邊我們使用另一個磁碟分割工具 `cfdisk` 來建立分割區。當然，你也可以使用 `parted` 完成操作。

進入 cfdisk 介面並操作：
```bash
# 如果有跳出分割表選單，選擇 "GPT"
sudo cfdisk /dev/sda

# EFI 分割區：
# 1. 選擇 [New]
# 2. Partition size: 512M
# 3. 選擇 [Type]: EFI System

# Btrfs 分割區：
# 1. 選擇 [New]
# 2. Partition size: 剩餘全部空間
# 3. 選擇 [Type]: Linux filesystem

# 選擇 [Write]
# 輸入 yes
# 選擇 [Quit]

# 確認結果
lsblk /dev/sda
```

預期結構：
```
NAME   SIZE TYPE
sda    256G disk
├─sda1 512M part   ← EFI
└─sda2 255G part   ← root
```

#### 2.2.2 格式分割區

```bash
# EFI： FAT32 格式
sudo mkfs.fat -F 32 -n esp-boot /dev/sda1

# Root：Btrfs 格式
sudo mkfs.btrfs -L nixos-root /dev/sda2
```

> [!NOTE]
> 若 Live ISO 沒有 `mkfs.btrfs` 或 `btrfs`，請執行：
> `nix-shell -p btrfs-progs`

#### 2.2.3 建立基礎子卷

先暫時掛載 Btrfs 的 top-level，再建立 `@`、`@home`、`@swap`：

```bash
sudo mount /dev/sda2 /mnt

sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@swap

# 確認子卷
sudo btrfs subvolume list /mnt

sudo umount /mnt
```

預期至少會看到：

```text
path @
path @home
path @swap
```

#### 2.2.4 掛載子卷

依照實際系統掛載點重新掛載，Root 使用 `zstd` 透明壓縮並關閉 atime：

```bash
# Root 子卷（/）
sudo mount -o subvol=@,compress=zstd,noatime /dev/disk/by-label/nixos-root /mnt

# Home 子卷（/home）
sudo mkdir -p /mnt/home
sudo mount -o subvol=@home,compress=zstd,noatime /dev/disk/by-label/nixos-root /mnt/home

# Swap 子卷（/swap）
sudo mkdir -p /mnt/swap
sudo mount -o subvol=@swap,noatime /dev/disk/by-label/nixos-root /mnt/swap

# EFI（/boot）
sudo mkdir -p /mnt/boot
sudo mount -o umask=077 /dev/disk/by-label/esp-boot /mnt/boot

# 確認掛載點與選項
findmnt /mnt
findmnt /mnt/home
findmnt /mnt/swap
findmnt /mnt/boot
```

> [!NOTE]
> - `compress=zstd` 只影響新寫入且適合壓縮的資料
> - `noatime` 避免每次讀取檔案都更新 access time

#### 2.2.5 建立 Btrfs swapfile

Btrfs swapfile 必須是預先配置、NODATACOW 且未壓縮的檔案。使用
`btrfs filesystem mkswapfile` 會建立符合這些條件的 swapfile：

```bash
# 以下以 8 GB 為例，請依 RAM 與需求調整
sudo btrfs filesystem mkswapfile --size 8G /mnt/swap/swapfile
sudo swapon /mnt/swap/swapfile

# 確認已啟用
swapon --show
```

> [!IMPORTANT]
> 記得在 `~/.config/nixfiles/configuration.nix` 加入以下設定
> **configuration.nix**
> ```nix
> swapDevices = [
>   { device = "/swap/swapfile"; }
> ];
> ```
>
> ⚠️ *不是* `nixos-generate-config` 產生的檔案 ⚠️
> 同時必須在 `nixos-config/flake.nix` 的 `modules` 中反註解
> `./configuration.nix`，並確保該檔案已加入 Git index，flake 才會載入它。
>
> **加入 Git index**
> ```bash
> git add -f configuration.nix
> ```

> [!WARNING]
> 含有啟用中 swapfile 的 `@swap` 不可建立快照，也不要替 swapfile 啟用壓縮。
> 若需要休眠，還必須另外設定正確的 resume device 與 Btrfs
> resume offset；本節只完成一般 swap。希望採用最簡單休眠配置時，可沿用
> 原本的 swap partition 方案。

#### 2.2.6 增加其他子卷

額外子卷適合用來建立獨立快照邊界。例如將 `/var/log` 放在 `@log`，可避免
回滾 root 快照時一併回滾系統紀錄。

如果 Btrfs top-level 還掛載在 `/mnt` 的話，可直接建立：

```bash
sudo btrfs subvolume create /mnt/@log
```

但若已完成前面的重新掛載，就需要先另外掛載 top-level：

```bash
sudo mkdir -p /mnt/btrfs-root
sudo mount -o subvolid=5 /dev/sda2 /mnt/btrfs-root
sudo btrfs subvolume create /mnt/btrfs-root/@log
sudo umount /mnt/btrfs-root
sudo rmdir /mnt/btrfs-root
```

接著建立掛載點並掛載：

```bash
sudo mkdir -p /mnt/var/log
sudo mount -o subvol=@log,compress=zstd,noatime /dev/sda2 /mnt/var/log
```

最後在 `hardware-configuration.nix` 加入對應宣告：

```nix
fileSystems."/var/log" = {
  device = "/dev/disk/by-uuid/<BTRFS-UUID>";
  fsType = "btrfs";
  options = [ "subvol=@log" "noatime" "compress=zstd" ];
};
```

參考資料：[NixOS Wiki：Btrfs](https://wiki.nixos.org/wiki/Btrfs)、
[Btrfs 文件：mount options 與 swapfile](https://btrfs.readthedocs.io/en/latest/btrfs-man5.html)。

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
   ~/.config/nixfiles/hardware-configuration.nix
```

確認硬碟掛載內容正確：
```bash
cat ~/.config/nixfiles/hardware-configuration.nix
# 查看是否有 fileSystems."/" 和 fileSystems."/boot"
# Btrfs 配置另確認 fileSystems."/home"、fileSystems."/swap" 及各自的 options
```

**Btrfs options example**
```nix
fileSystems."/" = {
  device = "/dev/disk/by-uuid/<BTRFS-UUID>";
  fsType = "btrfs";
  options = [ "subvol=@" "noatime" "compress=zstd" ];
};

fileSystems."/home" = {
  device = "/dev/disk/by-uuid/<BTRFS-UUID>";
  fsType = "btrfs";
  options = [ "subvol=@home" "noatime" "compress=zstd" ];
};

fileSystems."/swap" = {
  device = "/dev/disk/by-uuid/<BTRFS-UUID>";
  fsType = "btrfs";
  options = [ "subvol=@swap" "noatime" ];
};
```

**讓 Nix 看到這個檔案**：

Nix flake 只讀取 git 追蹤的檔案。`hardware-configuration.nix` 已在 `.gitignore` 中排除（機器專屬、不應提交），因此需要手動 stage：

```bash
cd ~/.config/nixfiles
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
cd ~/.config/nixfiles
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

#### **套用系統設定**：

```bash
update ~/.config/nixfiles # 等同 sudo nixos-rebuild switch --flake ~/.config/nixfiles#<hostname>
```
或
```bash
cd ~/.config/nixfiles
update           # 等同 sudo nixos-rebuild switch --flake .#<hostname>
```
> [!IMPORTANT]
> 如果你有覆蓋 Template 設定的需求，可以 Clone/Fork：[nixos-template](https://github.com/RemiErr/nixos-template)，將 Template 指向新的位置，並於修改後進行測試。
> ```bash
> update ~/.config/nixfiles \
> --override-input nixos-template path:~/<YOUR-LOCAL-PATH>/nixos-template
> ```

#### **套用 Home Manager 設定**：

```bash
hm ~/.config/nixfiles  # 等同 home-manager switch --flake ~/.config/nixfiles#<username>@<hostname>
```
或
```bash
cd ~/.config/nixfiles
hm            # 等同 home-manager switch --flake .#<username>@<hostname>
```

#### **更新 template（拉取本 repo 的最新版本）**：

```bash
cd ~/.config/nixfiles
nix flake update nixos-template
update
```

#### **清理舊世代**：

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
