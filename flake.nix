{
  description = "NixOS Flakes Setting";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";  # 僅用於 niri（blur 支援）

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # noctalia-shell 需要 nixos-unstable，不跟隨本 repo 的 nixpkgs
    noctalia-shell.url = "github:noctalia-dev/noctalia-shell";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};
    in
    {
      # ── NixOS 主機設定 ──────────────────────────────────────────────
      # 新增主機：複製 nixos 區塊，改 key 與 hosts/ 路徑即可
      nixosConfigurations = {

        # ── 主要主機：nixos（Niri + Wayland）────────────────────────
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              # niri 從 unstable 取得以支援 background_blur
              programs.niri.package = inputs.nixpkgs-unstable.legacyPackages.${system}.niri;
            }
            {
              home-manager.useGlobalPkgs      = true;
              home-manager.useUserPackages    = true;
              home-manager.extraSpecialArgs   = { inherit inputs; };
              home-manager.users.user         = import ./home/default.nix; # CHANGE: replace "user" with your username (must match users.nix and home/default.nix)
              home-manager.backupFileExtension = "bak";
            }
          ];
        };

      };

      # ── 獨立 Home Manager（非 NixOS 系統使用）──────────────────────
      homeConfigurations = {
        "user@nixos" = home-manager.lib.homeManagerConfiguration { # CHANGE: replace "user" with your username, "nixos" is your hostname
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./home/default.nix ];
        };
      };
    };
}
