{
  description = "NixOS Flakes Setting";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
              home-manager.useGlobalPkgs      = true;
              home-manager.useUserPackages    = true;
              home-manager.extraSpecialArgs   = { inherit inputs; };
              home-manager.users.user         = import ./home/default.nix; # CHANGE: replace "user" with your username (must match users.nix and home/default.nix)
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
