{
  description = "Jupyter dev environment with Python Full/Mini and VSCodium";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        kernels = import ./kernels.nix { inherit pkgs; };
        settings = import ./settings.nix { inherit pkgs; };
        extensions = import ./extensions.nix { inherit pkgs; };
 
        codium = pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = extensions;
        };
      in {
        devShells.default = pkgs.mkShell {
        packages = [ codium kernels.pythonFull ];
        shellHook = ''
          mkdir -p "$PWD/.kernels"
          mkdir -p "$PWD/.vscode/User"
          sed "s|__PWD__|$PWD|g" ${settings} > "$PWD/.vscode/User/settings.json"
          codium --user-data-dir="$PWD/.vscode" "$PWD"
        '';
        };

      }
    );
}