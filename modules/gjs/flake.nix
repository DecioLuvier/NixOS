{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            gjs
            gtk4
            gtk4-layer-shell
            glib
            gobject-introspection

            pango

            networkmanager
            wireplumber
            upower

            pkg-config
          ];

          shellHook = ''
            export XDG_DATA_DIRS="$GSETTINGS_SCHEMAS_PATH:$XDG_DATA_DIRS"
            export GI_TYPELIB_PATH="${pkgs.gtk4-layer-shell}/lib/girepository-1.0:${pkgs.gobject-introspection}/lib/girepository-1.0:$GI_TYPELIB_PATH"
            export LD_PRELOAD="${pkgs.gtk4-layer-shell}/lib/libgtk4-layer-shell.so"

            export GDK_DEBUG=no-portals
            gjs -m modules/app.js
          '';
        };
      });
}