{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
    # systemd.enable = true 讓 waybar 由 systemd user service 啟動
    # 與 niri 的 graphical-session.target 整合
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };

    settings = [{
      layer    = "top";
      position = "top";
      height   = 34;
      spacing  = 4;
      margin-top = 0;
      margin-bottom = 0;

      modules-left   = [ "niri/workspaces" "niri/window" ];
      modules-center = [ "clock" ];
      modules-right  = [
        "pulseaudio"
        "network"
        "battery"
        "cpu"
        "memory"
        "tray"
        "custom/power"
      ];

      # ── 左側模組 ────────────────────────────────────────────
      "niri/workspaces" = {
        format       = "{icon}";
        format-icons = {
          active  = "●";
          default = "○";
          urgent  = "!";
        };
      };

      "niri/window" = {
        max-length   = 60;
        rewrite      = {
          "(.*) — Mozilla Firefox" = "  $1";
          "(.*) - kitty"           = "  $1";
          "kitty"                  = " ";
        };
      };

      # ── 中間模組 ────────────────────────────────────────────
      clock = {
        format         = "  {:%H:%M}";
        format-alt     = "  {:%Y-%m-%d %H:%M:%S}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        calendar = {
          mode          = "year";
          mode-mon-col  = 3;
          weeks-pos     = "right";
          on-scroll     = 1;
          format = {
            months   = "<span color='#cba6f7'><b>{}</b></span>";
            days     = "<span color='#cdd6f4'>{}</span>";
            weeks    = "<span color='#6c7086'>W{}</span>";
            weekdays = "<span color='#89b4fa'><b>{}</b></span>";
            today    = "<span color='#f38ba8'><b><u>{}</u></b></span>";
          };
        };
      };

      # ── 右側模組 ────────────────────────────────────────────
      pulseaudio = {
        format          = "{icon}  {volume}%";
        format-muted    = "  靜音";
        format-icons = {
          default  = [ "" "" "" ];
          headphone = " ";
          headset   = " ";
        };
        on-click       = "pavucontrol";
        on-scroll-up   = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        scroll-step    = 5;
        tooltip-format = "{desc}";
      };

      network = {
        format-wifi        = "  {essid} ({signalStrength}%)";
        format-ethernet    = "  {ipaddr}/{cidr}";
        format-disconnected = "  未連線";
        format-disabled    = "  已停用";
        tooltip-format-wifi     = "  {ifname}\n  {essid}\n頻率: {frequency}GHz\n信號: {signalStrength}%\n延遲: {gwaddr}";
        tooltip-format-ethernet = "  {ifname}\n  {ipaddr}/{cidr}\n閘道: {gwaddr}";
        on-click           = "kitty -e nmtui";
      };

      battery = {
        bat    = "BAT0";
        states = {
          good     = 80;
          warning  = 30;
          critical = 10;
        };
        format          = "{icon}  {capacity}%";
        format-charging = "  {capacity}%";
        format-plugged  = "  {capacity}%";
        format-icons    = [ "" "" "" "" "" ];
        tooltip-format  = "電量: {capacity}%\n{timeTo}\n功耗: {power}W";
      };

      cpu = {
        interval      = 5;
        format        = "  {usage}%";
        tooltip       = false;
        on-click      = "kitty -e btop";
      };

      memory = {
        interval      = 10;
        format        = "  {used:0.1f}G";
        tooltip-format = "已用: {used:0.1f}G / {total:0.1f}G\n可用: {avail:0.1f}G";
        on-click      = "kitty -e btop";
      };

      tray = {
        icon-size    = 16;
        spacing      = 8;
        show-passive-items = true;
      };

      "custom/power" = {
        format   = " ";
        on-click = "wlogout";
        tooltip  = false;
      };
    }];

    # ── 樣式（Catppuccin Mocha 主題）────────────────────────────
    style = ''
      /* ── 顏色變數（Catppuccin Mocha）── */
      @define-color base    #1e1e2e;
      @define-color mantle  #181825;
      @define-color crust   #11111b;
      @define-color text    #cdd6f4;
      @define-color subtext1 #bac2de;
      @define-color overlay0 #6c7086;
      @define-color surface0 #313244;
      @define-color surface1 #45475a;
      @define-color surface2 #585b70;
      @define-color blue    #89b4fa;
      @define-color lavender #b4befe;
      @define-color sapphire #74c7ec;
      @define-color sky     #89dceb;
      @define-color teal    #94e2d5;
      @define-color green   #a6e3a1;
      @define-color yellow  #f9e2af;
      @define-color peach   #fab387;
      @define-color red     #f38ba8;
      @define-color maroon  #eba0ac;
      @define-color mauve   #cba6f7;
      @define-color pink    #f5c2e7;
      @define-color flamingo #f2cdcd;

      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", "Noto Sans CJK TC", sans-serif;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background-color: alpha(@base, 0.92);
        color: @text;
        transition-property: background-color;
        transition-duration: 0.3s;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        padding: 2px 8px;
      }

      /* ── 工作區 ── */
      #workspaces button {
        padding: 4px 10px;
        color: @overlay0;
        background-color: transparent;
        border-bottom: 2px solid transparent;
        transition: all 0.2s ease;
      }

      #workspaces button.active {
        color: @blue;
        border-bottom-color: @blue;
      }

      #workspaces button.urgent {
        color: @red;
        border-bottom-color: @red;
      }

      #workspaces button:hover {
        background-color: alpha(@surface0, 0.6);
        color: @text;
      }

      /* ── 視窗標題 ── */
      #window {
        color: @subtext1;
        padding: 0 4px;
      }

      /* ── 時鐘 ── */
      #clock {
        color: @blue;
        font-weight: bold;
      }

      /* ── 音量 ── */
      #pulseaudio {
        color: @lavender;
        padding: 0 8px;
      }
      #pulseaudio.muted {
        color: @overlay0;
      }

      /* ── 網路 ── */
      #network {
        color: @mauve;
        padding: 0 8px;
      }
      #network.disconnected {
        color: @red;
      }

      /* ── 電池 ── */
      #battery {
        color: @green;
        padding: 0 8px;
      }
      #battery.warning:not(.charging) {
        color: @yellow;
      }
      #battery.critical:not(.charging) {
        color: @red;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
      #battery.charging, #battery.plugged {
        color: @teal;
      }

      /* ── CPU / 記憶體 ── */
      #cpu {
        color: @peach;
        padding: 0 6px;
      }
      #memory {
        color: @sapphire;
        padding: 0 6px;
      }

      /* ── 系統匣 ── */
      #tray {
        padding: 0 4px;
      }
      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      /* ── 電源按鈕 ── */
      #custom-power {
        color: @red;
        padding: 0 12px;
        font-size: 16px;
      }
      #custom-power:hover {
        background-color: alpha(@red, 0.2);
      }

      /* ── 閃爍動畫（低電量）── */
      @keyframes blink {
        to { color: @base; background-color: @red; }
      }
    '';
  };
}
