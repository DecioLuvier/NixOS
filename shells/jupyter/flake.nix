{
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

        codium-base = pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = extensions;
        };

        jupyter-env = pkgs.writeShellScriptBin "jupyter-env" ''
          export PATH="${pkgs.coreutils}/bin:${kernels.pythonFull}/bin:${kernels.pythonData}/bin:$PATH"
          
          export VSCODE_USER_DATA="$(mktemp -d)"
          
          mkdir -p "$VSCODE_USER_DATA/User"
          cp ${settings} "$VSCODE_USER_DATA/User/settings.json"
        
          export HOME="/tmp/nix-jupyter-pure"
          mkdir -p "$HOME"

          # Abre o Codium com o diretório de dados isolado
          exec ${codium-base}/bin/codium --user-data-dir="$VSCODE_USER_DATA" "$@"
        '';

      in {
        packages.default = jupyter-env;
      }
    );
}
