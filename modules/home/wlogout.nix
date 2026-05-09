{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ wlogout ];

  # ── 選單佈局 ────────────────────────────────────────────────────
  xdg.configFile."wlogout/layout".text = ''
    {
        "label" : "lock",
        "action" : "hyprlock",
        "text" : "鎖定",
        "keybind" : "l"
    }
    {
        "label" : "suspend",
        "action" : "systemctl suspend",
        "text" : "睡眠",
        "keybind" : "u"
    }
    {
        "label" : "logout",
        "action" : "niri msg action quit --skip-confirmation",
        "text" : "登出",
        "keybind" : "e"
    }
    {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "關機",
        "keybind" : "s"
    }
    {
        "label" : "hibernate",
        "action" : "systemctl hibernate",
        "text" : "休眠",
        "keybind" : "h"
    }
    {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "重新開機",
        "keybind" : "r"
    }
  '';

  # ── 樣式（Catppuccin Mocha）─────────────────────────────────────
  xdg.configFile."wlogout/style.css".text = ''
    * {
        background-image: none;
        font-family: "Noto Sans CJK TC", "JetBrainsMono Nerd Font", sans-serif;
        font-size: 14px;
    }

    window {
        background-color: rgba(17, 17, 27, 0.85);
    }

    button {
        color: #cdd6f4;
        background-color: rgba(30, 30, 46, 0.9);
        border-style: solid;
        border-width: 2px;
        border-color: rgba(49, 50, 68, 0.8);
        border-radius: 12px;
        background-repeat: no-repeat;
        background-position: center top 35%;
        background-size: 28%;
        margin: 12px;
        padding-top: 100px;
        transition: all 0.25s ease;
    }

    button:focus,
    button:active,
    button:hover {
        background-color: rgba(49, 50, 68, 0.95);
        border-color: #89b4fa;
        outline-style: none;
        color: #cdd6f4;
    }

    /* 各按鈕圖示（使用 nerd font Unicode）*/
    #lock {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png"));
    }
    #suspend {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"));
    }
    #logout {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png"));
    }
    #shutdown {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"));
    }
    #hibernate {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png"));
    }
    #reboot {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"));
    }
  '';
}
