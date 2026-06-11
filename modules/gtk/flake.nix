{
  description = "A development environment for GTKmm 4 applications";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        my-app = pkgs.stdenv.mkDerivation {
          pname = "my-app";
          version = "0.1.0";
          src = ./.;

          nativeBuildInputs = with pkgs; [
            gcc
            pkg-config
            wrapGAppsHook4
          ];

          buildInputs = with pkgs; [
            gtkmm4
            glibmm
          ];

          buildPhase = ''
            g++ modules/main.cpp -o my_app $(pkg-config --cflags --libs gtkmm-4.0)
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp my_app $out/bin/my_app
          '';

          postFixup = ''
            wrapProgram $out/bin/my_app --set GDK_DEBUG no-portals
          '';
        };
      in {
        packages.default = my-app;

        apps.default = {
          type = "app";
          program = "${my-app}/bin/my_app";
        };
      });
}