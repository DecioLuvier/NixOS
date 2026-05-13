{
  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.default = pkgs.stdenv.mkDerivation {
        pname   = "my-shell";
        version = "0.1.0";
        src     = ./modules;

        nativeBuildInputs = with pkgs; [
          wrapGAppsHook4
          gobject-introspection
        ];

        buildInputs = with pkgs; [
          gjs
          gtk4
          gtk4-layer-shell
          glib
          networkmanager
          wireplumber
          upower
        ];

        installPhase = ''
          mkdir -p $out/bin $out/share/my-shell
          cp -r . $out/share/my-shell
          makeWrapper ${pkgs.gjs}/bin/gjs $out/bin/my-shell \
            --add-flags "-m $out/share/my-shell/app.js"
        '';

        preFixup = ''
          gappsWrapperArgs+=(
            --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [
              networkmanager
              wireplumber
              playerctl
              xdg-utils
              brightnessctl
            ])}
            --set LD_PRELOAD ${pkgs.gtk4-layer-shell}/lib/libgtk4-layer-shell.so
          )
        '';
      };

      apps.default = {
        type    = "app";
        program = "${self.packages.${system}.default}/bin/my-shell";
      };
    });
}
