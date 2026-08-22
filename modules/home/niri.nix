{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    xwayland-satellite  # X11 應用程式相容層（無需重新編譯）
    swayidle            # 閒置後自動鎖屏
  ];

  # ── 閒置管理（10 分鐘後鎖屏，20 分鐘後鎖屏並睡眠）───────────────
  services.swayidle = {
    enable    = true;
    timeouts  = [
      { timeout = 600;  command = "noctalia msg session lock"; }
      { timeout = 1200; command = "noctalia msg session lock-and-suspend"; }
    ];
    events = [
      # before-sleep：涵蓋非本設定觸發的睡眠，確保睡眠前一定鎖屏。
      { event = "before-sleep"; command = "noctalia msg session lock"; }
      { event = "lock";         command = "noctalia msg session lock"; }
    ];
  };

  # ── niri 設定檔（KDL 格式）──────────────────────────────────────
  # 文件：https://github.com/YaLTeR/niri/wiki/Configuration:-Overview
  # 查詢可用螢幕名稱：niri msg outputs
  # 查詢可用按鍵名稱：niri msg event-stream （按鍵時查看輸出）
  xdg.configFile."niri/config.kdl".text = ''
    // ── 輸入裝置 ──────────────────────────────────────────────────
    input {
        keyboard {
            xkb {
                layout "us"
                // fcitx5 處理中文輸入，此處維持 us 佈局
            }
            repeat-delay 500
            repeat-rate  30
        }

        touchpad {
            tap                         // 點擊即按下
            natural-scroll              // 自然捲動
            accel-speed 0.2
            accel-profile "adaptive"
            scroll-method "two-finger"
            dwt                         // 打字時停用（disable while typing）
        }

        mouse {
            accel-speed 0.0
            accel-profile "flat"
        }

        focus-follows-mouse max-scroll-amount="0%"
        warp-mouse-to-focus
    }

    // ── 螢幕設定 ────────────────────────────────────────────────
    // 查詢螢幕名稱：niri msg outputs
    // 縮放比例 1.25 適合 2K 螢幕，1.5 適合 4K
    output "eDP-1" {
        scale 1.0
        // mode "1920x1080@60.000"  // 取消注解以強制指定解析度
    }
    // 外接螢幕範例：
    // output "HDMI-A-1" {
    //     scale 1.0
    //     position x=1920 y=0
    // }

    // ── 版面配置 ────────────────────────────────────────────────
    layout {
        gaps 10
        center-focused-column "never"
        always-center-single-column

        preset-column-widths {
            proportion 0.333
            proportion 0.5
            proportion 0.667
            proportion 1.0
        }

        default-column-width {
            proportion 0.5
        }

        focus-ring {
            width 2
            active-color   "rgba(20,19,17,0.35)"
            inactive-color "rgba(20,19,17,0.85)"
        }

        border {
            off
        }

        shadow {
            on
            softness 20
            spread 2
            offset x=-4 y=-4
            color "rgba(0, 0, 0, 0.7)"
        }

        struts {
            left   6
            right  6
            top    8
            bottom 10
        }
    }

    // ── 啟動時執行 ──────────────────────────────────────────────
    spawn-at-startup "fcitx5" "-d" "--replace"
    // v5 起 noctalia 已改為原生 C++/OpenGL、非 Qt/QML，故不再需要
    // QT_IM_MODULE=none / XMODIFIERS=@im=none 這組給 Qt 用的 IME workaround。
    spawn-at-startup "noctalia"
    spawn-at-startup "xwayland-satellite"

    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    animations {
        slowdown 0.98
        workspace-switch {
            spring damping-ratio=0.82 stiffness=400 epsilon=0.0001
        }
        horizontal-view-movement {
            spring damping-ratio=0.84 stiffness=400 epsilon=0.0001
        }
        window-open {
            spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
        }
        window-close {
            spring damping-ratio=0.8 stiffness=400 epsilon=0.0001
        }
        window-movement {
            spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
        }
        window-resize {
            spring damping-ratio=0.9 stiffness=500 epsilon=0.0001
        }
    }

    // ── 視窗通用規則 ────────────────────────────────────────────
    window-rule {
        geometry-corner-radius 20
        clip-to-geometry true
    }

    // Firefox 畫中畫
    window-rule {
        match app-id=r#"firefox"# title=r#"Picture-in-Picture"#
        open-floating true
    }

    // ── 按鍵綁定 ────────────────────────────────────────────────
    // Mod = Super/Windows 鍵
    // 查看所有可用 action：niri msg action list

    binds {
        // ── 應用程式 ─────────────────────────────────────────
        Mod+Return  { spawn "foot"; }
        Mod+Space     hotkey-overlay-title="功能選單" { spawn-sh "dms ipc call spotlight toggle"; }
        Mod+Ctrl+L     hotkey-overlay-title="鎖屏（Lock）" { spawn-sh "dms ipc call lock lock"; }
        Mod+Ctrl+P     hotkey-overlay-title="電源選單（Power Menu）" { spawn-sh "dms ipc call powermenu toggle"; }
        Mod+N             hotkey-overlay-title="通知（Notifications）" { spawn-sh "dms ipc call notifications toggle"; }

        // 截圖（grim + slurp）
        Print          hotkey-overlay-title="截圖" { screenshot; }
        Ctrl+Print     hotkey-overlay-title="全螢幕截圖" { screenshot-screen; }
        Alt+Print      hotkey-overlay-title="視窗截圖" { screenshot-window; }
        Mod+Shift+S    hotkey-overlay-title="選取範圍截圖" { spawn "sh" "-c" "grim -g \"$(slurp)\" - | swappy -f -"; }

        // 剪貼簿歷史（DankMaterialShell 內建）
        Mod+V hotkey-overlay-title="剪貼簿歷史" { spawn-sh "dms ipc call clipboard toggle"; }

        // ── 視窗焦點（vim 鍵 + 方向鍵）──────────────────────
        Mod+Left         hotkey-overlay-title="聚焦左邊視窗" { focus-column-left; }
        Mod+Right      hotkey-overlay-title="聚焦右邊視窗" { focus-column-right; }
        Mod+Down      hotkey-overlay-title="聚焦下面視窗" { focus-window-down; }
        Mod+Up           hotkey-overlay-title="聚焦上面視窗" { focus-window-up; }

        // 焦點跳到欄首/欄尾
        Mod+Home       hotkey-overlay-title="焦點跳到欄首" { focus-column-first; }
        Mod+End           hotkey-overlay-title="焦點跳到欄尾" { focus-column-last; }

        // ── 視窗移動 ─────────────────────────────────────────
        Mod+Shift+Left     { move-column-left; }
        Mod+Shift+Right     { move-column-right; }
        Mod+Shift+Down     { move-window-down; }
        Mod+Shift+Up     { move-window-up; }
        Mod+Shift+Home  { move-column-to-first; }
        Mod+Shift+End   { move-column-to-last; }

        // ── 視窗大小 ─────────────────────────────────────────
        Mod+R           { switch-preset-column-width; }
        Mod+Shift+R     { reset-window-height; }
        Mod+F          hotkey-overlay-title="最大化視窗" { maximize-column; }
        Mod+Shift+F    hotkey-overlay-title="全螢幕視窗" { fullscreen-window; }
        Mod+C          hotkey-overlay-title="置中視窗" { center-column; }
        Mod+Minus       { set-column-width "-10%"; }
        Mod+Equal       { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        // ── 視窗管理 ─────────────────────────────────────────
        Mod+Q              hotkey-overlay-title="關閉視窗" { close-window; }
        Mod+T               hotkey-overlay-title="切換浮動視窗" { toggle-window-floating; }
        Mod+Shift+C    hotkey-overlay-title="排序置中視窗" { consume-window-into-column; }
        Mod+X               hotkey-overlay-title="取消置中視窗" { expel-window-from-column; }

        // ── 工作區 ───────────────────────────────────────────
        Mod+1          hotkey-overlay-title="聚焦工作區 1" { focus-workspace 1; }
        Mod+2          hotkey-overlay-title="聚焦工作區 2" { focus-workspace 2; }
        Mod+3          hotkey-overlay-title="聚焦工作區 3" { focus-workspace 3; }
        Mod+4          hotkey-overlay-title="聚焦工作區 4" { focus-workspace 4; }
        Mod+5          hotkey-overlay-title="聚焦工作區 5" { focus-workspace 5; }
        Mod+6          hotkey-overlay-title="聚焦工作區 6" { focus-workspace 6; }
        Mod+7          hotkey-overlay-title="聚焦工作區 7" { focus-workspace 7; }
        Mod+8          hotkey-overlay-title="聚焦工作區 8" { focus-workspace 8; }
        Mod+9          hotkey-overlay-title="聚焦工作區 9" { focus-workspace 9; }
        Mod+Shift+1    hotkey-overlay-title="移動到工作區 1" { move-column-to-workspace 1; }
        Mod+Shift+2    hotkey-overlay-title="移動到工作區 2" { move-column-to-workspace 2; }
        Mod+Shift+3    hotkey-overlay-title="移動到工作區 3" { move-column-to-workspace 3; }
        Mod+Shift+4    hotkey-overlay-title="移動到工作區 4" { move-column-to-workspace 4; }
        Mod+Shift+5    hotkey-overlay-title="移動到工作區 5" { move-column-to-workspace 5; }
        Mod+Shift+6    hotkey-overlay-title="移動到工作區 6" { move-column-to-workspace 6; }
        Mod+Shift+7    hotkey-overlay-title="移動到工作區 7" { move-column-to-workspace 7; }
        Mod+Shift+8    hotkey-overlay-title="移動到工作區 8" { move-column-to-workspace 8; }
        Mod+Shift+9    hotkey-overlay-title="移動到工作區 9" { move-column-to-workspace 9; }
        Mod+Tab        hotkey-overlay-title="切換工作區" { focus-workspace-previous; }
        Mod+Page_Down hotkey-overlay-title="聚焦下一個工作區"  { focus-workspace-down; }
        Mod+Page_Up      hotkey-overlay-title="聚焦上一個工作區" { focus-workspace-up; }
        Mod+Ctrl+Down   hotkey-overlay-title="移動到下一個工作區" { move-column-to-workspace-down; }
        Mod+Ctrl+Up        hotkey-overlay-title="移動到上一個工作區" { move-column-to-workspace-up; }
        Mod+WheelScrollDown cooldown-ms=150 hotkey-overlay-title="聚焦下一個工作區" { focus-workspace-down; }
        Mod+WheelScrollUp   cooldown-ms=150 hotkey-overlay-title="聚焦上一個工作區" { focus-workspace-up; }
        Mod+Ctrl+WheelScrollDown cooldown-ms=150 hotkey-overlay-title="移動到下一個工作區" { move-column-to-workspace-down; }
        Mod+Ctrl+WheelScrollUp   cooldown-ms=150 hotkey-overlay-title="移動到上一個工作區" { move-column-to-workspace-up; }

        // ── 系統媒體 / 音量 / 亮度（DankMaterialShell IPC）────
        XF86AudioRaiseVolume  allow-when-locked=true { spawn-sh "dms ipc call audio increment"; }
        XF86AudioLowerVolume  allow-when-locked=true { spawn-sh "dms ipc call audio decrement"; }
        XF86AudioMute         allow-when-locked=true { spawn-sh "dms ipc call audio mute"; }
        XF86AudioMicMute      { spawn-sh "dms ipc call mic mute"; }
        XF86MonBrightnessUp   { spawn-sh "dms ipc call brightness increment"; }
        XF86MonBrightnessDown { spawn-sh "dms ipc call brightness decrement"; }
        XF86AudioPlay         { spawn-sh "dms ipc call mpris playPause"; }
        XF86AudioNext         { spawn-sh "dms ipc call mpris next"; }
        XF86AudioPrev         { spawn-sh "dms ipc call mpris previous"; }

        // ── niri 說明 ────────────────────────────────────────
        Mod+Shift+Slash { show-hotkey-overlay; }
        Mod+Escape      { spawn "sh" "-c" "niri msg action quit --skip-confirmation"; }
    }
  '';
}
