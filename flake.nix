{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    
    nixosConfigurations.laptop-luvier = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [ 
          { nixpkgs.overlays = [ self.overlays.default ]; }
          home-manager.nixosModules.home-manager

          ./hosts/laptop/default.nix
          ./hosts/laptop/hardware.nix
          ./hosts/laptop/profile/luvier.nix
        ];
      };
  };
}