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
        {
          environment.systemPackages = [
            (ags.packages.x86_64-linux.default.override {
              extraPackages = [
                ags.packages.x86_64-linux.battery
                ags.packages.x86_64-linux.powerprofiles
                ags.packages.x86_64-linux.wireplumber
                ags.packages.x86_64-linux.network
                ags.packages.x86_64-linux.tray
                ags.packages.x86_64-linux.mpris
                ags.packages.x86_64-linux.apps
              ];
            })
          ];
        }
      ];
    };
  };
}