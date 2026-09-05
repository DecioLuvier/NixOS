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
    jupyter = {
      url = "path:./packages/jupyter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    desktop = {
      url = "path:./packages/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    navbar = {
      url = "path:./packages/navbar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, godot-mono, jupyter, desktop, navbar, ... }: {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        godot-mono.nixosModules.default
        jupyter.nixosModules.default
        desktop.nixosModules.default
        navbar.nixosModules.default
        ./hosts/laptop/hardware.nix
        ./hosts/laptop/default.nix
      ];
    };
  };
}
