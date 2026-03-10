{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, home-manager, ... }: {

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    nixosConfigurations.laptop-luvier = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [ { nixpkgs.overlays = [ self.overlays.default ]; }
        ./hosts/laptop/default.nix
        ./hosts/laptop/hardware.nix
        ./hosts/laptop/users/luvier.nix
      ];
    };

  };
}