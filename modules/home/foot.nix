{ pkgs, ... }:

{
  programs.foot = {
    enable = pkgs.stdenv.isLinux;
    server.enable = true;
    settings = {
      main = {
        term             = "foot";
        font             = "Maple Mono NF:size=13";
        dpi-aware        = "no";
        resize-keep-grid = "no";
      };
      colors-dark = {
        alpha = 0.72;
        # blur = true;  # 需要 foot >= 1.26 + compositor，VirtualBox 暫不啟用
      };
      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
