{
  description = "Hyprland desktop modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    inherit (nixpkgs) lib;
    supportedSystems = [
      "x86_64-linux"
    ];
    forAllSystems = f: lib.genAttrs supportedSystems (system: f system);
  in {

    formatter = forAllSystems (system:
      nixpkgs.legacyPackages.${system}.alejandra
    );

    nixosModules = {
      hyprland = import ./modules/hyprland.nix;
      hyprland-desktop = import ./modules/hyprland-desktop.nix;
      hyprpaper = import ./modules/hyprpaper.nix;
      mako = import ./modules/mako.nix;
      swaylock = import ./modules/swaylock.nix;
      waybar = import ./modules/waybar.nix;
      wlogout = import ./modules/wlogout.nix;
      wofi = import ./modules/wofi.nix;

      default = { ... }: {
        imports = [
          home-manager.nixosModules.home-manager
          self.nixosModules.hyprland-desktop
        ];
      };
    };

    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./configuration.nix
        self.nixosModules.default
      ];
    };

  };
}