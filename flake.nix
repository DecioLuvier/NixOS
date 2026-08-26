{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags.url = "github:Aylur/ags";
    nix-claude-code.url = "github:ryoppippi/nix-claude-code";
  };

  outputs = { self, nixpkgs, home-manager, ags, nix-claude-code, ... }: {
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
        ({ ... }: { nixpkgs.overlays = [ nix-claude-code.overlays.default ]; })

        home-manager.nixosModules.home-manager
        ./hosts/desktop/default.nix
        ./hosts/desktop/hardware.nix
        ./hosts/desktop/profiles/hyprland.nix
      ];
    };
  };
}