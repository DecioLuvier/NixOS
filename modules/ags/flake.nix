{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.astal.follows = "astal";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ags, astal }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.default = pkgs.stdenv.mkDerivation {
        pname = "my-shell";
        version = "0.1.0";
        src = ./.;

        nativeBuildInputs = [
          pkgs.wrapGAppsHook3
          pkgs.gobject-introspection
          ags.packages.${system}.default
        ];

        buildInputs = with ags.packages.${system}; [
          io
          astal4
          battery
          powerprofiles
          wireplumber
          network
          tray
          mpris
          apps
          hyprland
        ] ++ [ pkgs.glib pkgs.gjs ];

        installPhase = ''
          ags bundle app.tsx $out/bin/my-shell
        '';

        preFixup = ''
          gappsWrapperArgs+=(
            --prefix PATH : ${pkgs.lib.makeBinPath [
              pkgs.networkmanager
              pkgs.wireplumber
              pkgs.playerctl
              pkgs.brightnessctl
            ]}
          )
        '';
      };

      apps.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/my-shell";
      };
    });
}