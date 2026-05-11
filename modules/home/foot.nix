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
      colors = {
        alpha = "0.72";
        blur = true;
      };
      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
