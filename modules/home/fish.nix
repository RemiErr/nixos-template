{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      ll      = "ls -lahF --color=auto";
      la      = "ls -A --color=auto";
      grep    = "grep --color=auto";
      cls     = "clear";
      sos     = "source";
      py      = "python3";
      update  = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
      flakeup = "nix flake update";
      hm      = "home-manager switch --flake ~/nixos-config#user@nixos";
      gc      = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      gens    = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    };

    interactiveShellInit = ''
      set -g fish_greeting

      fish_add_path $HOME/.local/bin

      fish_vi_key_bindings

      function fish_user_key_bindings
        for mode in insert default
          bind -M $mode ctrl-backspace backward-kill-word
          bind -M $mode ctrl-z undo
          bind -M $mode ctrl-b beginning-of-line
          bind -M $mode ctrl-e end-of-line
        end
        bind -M insert up   history-prefix-search-backward
        bind -M insert down history-prefix-search-forward
        bind -M default up   history-prefix-search-backward
        bind -M default down history-prefix-search-forward
      end

      set fish_cursor_default     block
      set fish_cursor_insert      line
      set fish_cursor_replace_one underscore
      set fish_cursor_visual      block

      set -g fish_color_autosuggestion brblack
      set -g fish_color_command        blue
      set -g fish_color_error          red
      set -g fish_color_param          normal
      set -g fish_color_search_match   --background=normal
    '';

    functions = {
      fish_prompt = ''
        set_color green
        echo -n (whoami)@(hostname)
        set_color normal
        echo -n ':'
        set_color blue
        echo -n (prompt_pwd)
        set_color normal
        echo -n '$ '
      '';

      fm = ''
        set -l tmp (mktemp -t "yazi-cwd.XXXXX")
        yazi $argv --cwd-file $tmp
        set -l cwd (cat $tmp)
        if test -n "$cwd" -a "$cwd" != "$PWD"
          cd $cwd
        end
        rm -f $tmp
      '';
    };
  };
}
