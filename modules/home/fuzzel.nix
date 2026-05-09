{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ fuzzel ];

  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=13
    dpi-aware=no
    prompt=❯
    placeholder=搜尋應用程式或指令...
    terminal=kitty
    layer=overlay
    icon-theme=Papirus-Dark
    icons-enabled=yes
    fields=name,generic,comment,keywords,filename,exec
    width=40
    lines=12
    tabs=4
    horizontal-pad=16
    vertical-pad=12
    inner-pad=8
    image-size-ratio=0.4
    # 輸入時不區分大小寫
    fuzzy=no

    [colors]
    background=1e1e2eff
    text=cdd6f4ff
    match=89b4faff
    selection=313244ff
    selection-text=cdd6f4ff
    selection-match=89b4faff
    border=89b4fa99

    [border]
    width=2
    radius=8

    [dmenu]
    exit-immediately-if-empty=yes
  '';
}
