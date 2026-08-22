{
  description = "Reusable NixOS and Home Manager modules";

  outputs = { self }: {
    nixosModules.default = {
      imports = [
        ./modules/system/common.nix
        ./modules/system/wayland.nix
        ./modules/system/input-method.nix
        ./modules/system/users.nix
      ];
    };

    homeModules.default = import ./home.nix;
  };
}
