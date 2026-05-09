{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [ swww ];

  # ── 壁紙目錄佔位（確保目錄存在）────────────────────────────────
  home.file."Pictures/Wallpapers/.keep".text = "";

  # ── swww daemon systemd user service ────────────────────────────
  # 在 graphical-session.target 啟動後自動執行
  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "swww wallpaper daemon";
      Documentation = "https://github.com/LGFae/swww";
      PartOf    = [ "graphical-session.target" ];
      After     = [ "graphical-session-pre.target" ];
      Wants     = [ "graphical-session-pre.target" ];
    };
    Service = {
      ExecStart    = "${pkgs.swww}/bin/swww-daemon";
      Restart      = "on-failure";
      RestartSec   = "1s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ── 設定初始壁紙 ────────────────────────────────────────────────
  systemd.user.services.swww-init = {
    Unit = {
      Description = "swww initial wallpaper";
      After       = [ "swww-daemon.service" ];
      Requires    = [ "swww-daemon.service" ];
    };
    Service = {
      Type       = "oneshot";
      RemainAfterExit = true;
      ExecStart  = let
        setWallpaper = pkgs.writeShellScript "swww-set-wallpaper" ''
          # 等待 daemon 就緒
          sleep 1
          WALL_DIR="$HOME/Pictures/Wallpapers"
          DEFAULT="$WALL_DIR/default.jpg"

          if [ -f "$DEFAULT" ]; then
            ${pkgs.swww}/bin/swww img "$DEFAULT" \
              --transition-type  grow \
              --transition-pos   0.5,0.5 \
              --transition-duration 1.0
          else
            # 無壁紙時使用 Catppuccin Mocha base 純色
            ${pkgs.swww}/bin/swww clear "#1e1e2e"
          fi
        '';
      in "${setWallpaper}";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ── 壁紙切換腳本 ────────────────────────────────────────────────
  # 用法：set-wallpaper /path/to/image.jpg
  home.file.".local/bin/set-wallpaper" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      IMAGE="$1"

      if [ -z "$IMAGE" ]; then
        # 用 fuzzel 選取壁紙
        IMAGE=$(find "$HOME/Pictures/Wallpapers" \
          -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) \
          | fuzzel --dmenu --prompt "選擇壁紙 > ")
      fi

      if [ -n "$IMAGE" ] && [ -f "$IMAGE" ]; then
        ${pkgs.swww}/bin/swww img "$IMAGE" \
          --transition-type  grow \
          --transition-pos   0.5,0.5 \
          --transition-duration 1.0
        # 記錄路徑以便重啟後還原
        echo "$IMAGE" > "$HOME/.cache/swww-current-wallpaper"
      fi
    '';
  };
}
