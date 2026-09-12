{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jupyter = {
      url = "path:./packages/Jupyter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    P5RBoot = {
      url = "path:./packages/P5RBoot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    Bars = {
      url = "path:./packages/Bars";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, jupyter, P5RBoot, Bars, ... }: {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/laptop/hardware.nix
        ./hosts/laptop/default.nix
        ./packages/Hyprland
        home-manager.nixosModules.home-manager
        jupyter.nixosModules.default
        P5RBoot.nixosModules.default
        Bars.nixosModules.default
      ];
    };
  };
}
