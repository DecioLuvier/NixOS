{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }: {

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    overlays.default = final: prev: {
      onnx2c = final.callPackage ./pkgs/onnx2c.nix { };
    };

    devShells.${system} = {
      jupyter = pkgs.callPackage ./shells/jupyter.nix { };
    };

    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [ { nixpkgs.overlays = [ self.overlays.default ]; }
        ./hosts/laptop/configuration.nix
        home-manager.nixosModules.home-manager

        ./modules/hyprland.nix
        ./modules/swaybg.nix
        ./modules/mako.nix
        ./modules/waybar.nix
        ./modules/wlogout.nix
        ./modules/wofi.nix
      ];
    };

  };
}