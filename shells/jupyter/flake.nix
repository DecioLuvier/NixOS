{
  description = "Jupyter dev environment package with Python and VSCodium";

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

        codium-with-extensions = pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = extensions;
        };

        jupyter-env = pkgs.writeShellScriptBin "jupyter-env" ''
          # Estas pastas são criadas onde você RODAR o comando, não no build
          mkdir -p "$PWD/.kernels"
          mkdir -p "$PWD/.vscode/User"
          
          # Processa o settings.json
          sed "s|__PWD__|$PWD|g" ${settings} > "$PWD/.vscode/User/settings.json"
          
          # Garante que o Python do kernel esteja no PATH ao abrir o Codium
          export PATH="${kernels.pythonFull}/bin:$PATH"
          
          # Executa o Codium isolado
          exec ${codium-with-extensions}/bin/codium --user-data-dir="$PWD/.vscode" "$PWD"
        '';
      in {
        packages.default = jupyter-env;

        devShells.default = pkgs.mkShell {
          packages = [ jupyter-env ];
          shellHook = ''
            echo "Ambiente carregado. Digite 'jupyter-env' para iniciar."
          '';
        };
      }
    );
}