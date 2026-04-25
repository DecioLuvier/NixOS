{
  description = "NixOS + AGS com config no flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ags.url = "github:Aylur/ags";
  };

  outputs = { self, nixpkgs, ags, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.meu-pc = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = with pkgs; [
            ags.packages.${system}.default
            gjs
            gtk3
            gtk4
            libnotify
            sassc
          ];

          services.dbus.enable = true;

          # comando helper pra rodar o AGS com a config do flake
          environment.systemPackages = [
            (pkgs.writeShellScriptBin "ags-run" ''
              exec ${ags.packages.${system}.default}/bin/ags -c ${self}/ags/config.js
            '')
          ];
        })
      ];
    };
  };
}