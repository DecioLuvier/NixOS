{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags.url = "github:Aylur/ags";
  };

  outputs = { self, nixpkgs, home-manager, ags, ... }: {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/laptop/default.nix
        ./hosts/laptop/hardware.nix
        ./hosts/laptop/profiles/hyprland.nix
      ];
    };
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/desktop/default.nix
        ./hosts/desktop/hardware.nix
        ./hosts/desktop/profiles/hyprland.nix
      ];
    };
  };
}