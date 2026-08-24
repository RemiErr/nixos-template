{
  description = "Reusable NixOS and Home Manager modules";

  outputs = { self }: {
    nixosModules.default = {
      imports = [
        ./modules/system/common.nix
        ./modules/system/wayland.nix
        ./modules/system/input-method.nix
        ./modules/system/users.nix
        ./modules/system/gaming.nix
      ];
    };

    homeModules.default = import ./home.nix;

    lib.mkAmdAiShell = { pkgs }:
      import ./devshells/amd-ai.nix { inherit pkgs; };
  };
}
