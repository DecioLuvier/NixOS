{
  description = "Codium Jupyter App Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        settings   = import ./settings.nix { inherit pkgs self; };
        extensions = import ./extensions.nix { inherit pkgs; };
        kernels    = import ./kernels.nix { inherit pkgs self; };

        codium = pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = extensions;
        };

        codium-jupyter = pkgs.writeShellScriptBin "codium-jupyter" ''
          USER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/codium"
          mkdir -p "$USER_CONFIG"

          cp -r ${settings}/* "$USER_CONFIG/" 2>/dev/null || true
          cp -r ${extensions}/* "$USER_CONFIG/extensions/" 2>/dev/null || true

          exec ${codium}/bin/codium \
            --user-data-dir "$USER_CONFIG" \
            --extensions-dir "$USER_CONFIG/extensions" \
            "$@"
        '';
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            codium-jupyter
          ] ++ kernels.packages;

          shellHook = kernels.shellHook;
        };

        apps.default.codium-jupyter = flake-utils.lib.mkApp {
          drv = codium-jupyter;
        };
      }
    );
}