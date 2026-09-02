{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    godot-mono = {
      url = "path:./packages/godot-mono";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, godot-mono, ... }: {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit godot-mono; };
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/laptop/default.nix
        ./hosts/laptop/hardware.nix
        ./hosts/laptop/profiles/hyprland.nix
      ];
    };
  };
}