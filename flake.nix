{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
    navbar = {
      url = "path:./packages/navbar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    P5RBoot = {
      url = "path:./packages/P5RBoot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode = {
      url = "path:./packages/vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, godot-mono, jupyter, navbar, P5RBoot, vscode, ... }: {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit vscode; };
      modules = [
        home-manager.nixosModules.home-manager
        godot-mono.nixosModules.default
        jupyter.nixosModules.default
        ./packages/hyprland
        navbar.nixosModules.default
        P5RBoot.nixosModules.default
        ./hosts/laptop/hardware.nix
        ./hosts/laptop/default.nix
      ];
    };
  };
}
