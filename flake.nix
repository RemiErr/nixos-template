{
  description = "NixOS Flakes Setting";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # noctalia-shell repo 已改名為 noctalia-dev/noctalia，主線已進入 v5 beta
    # 此處釘選在改名前的最後一個 v4 穩定 tag，避免被 beta 破壞性變更影響。
    # 日後要升級 v5 需另外重寫 home/default.nix 的 noctalia 設定區塊與 niri.nix 的 IPC 指令。
    noctalia-shell.url = "github:noctalia-dev/noctalia/v4.7.3";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};
      vars   = import ./variables.nix;
    in
    {
      # ── Template Module Export（供外部 flake 引用）──────────────────
      # 外部 flake 透過 specialArgs / extraSpecialArgs 傳入 vars 與 inputs
      nixosModules.default = { ... }: {
        imports = [
          ./modules/system/common.nix
          ./modules/system/wayland.nix
          ./modules/system/input-method.nix
          ./modules/system/users.nix
        ];
      };

      homeModules.default = import ./home/default.nix;

      # ── NixOS 主機設定 ──────────────────────────────────────────────
      nixosConfigurations = {

        ${vars.hostname} = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs vars; };
          modules = [
            ./hosts/nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs      = true;
              home-manager.useUserPackages    = true;
              home-manager.extraSpecialArgs   = { inherit inputs vars; };
              home-manager.users.${vars.username} = import ./home/default.nix;
              home-manager.backupFileExtension = "bak";
            }
          ];
        };

      };

      # ── 獨立 Home Manager（非 NixOS 系統使用）──────────────────────
      homeConfigurations = {
        "${vars.username}@${vars.hostname}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs vars; };
          modules = [ ./home/default.nix ];
        };
      };
    };
}
