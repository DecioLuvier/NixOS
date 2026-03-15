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

        # 1. O VSCodium com as extensões
        codium-base = pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = extensions;
        };

        # 2. Um script que cria uma pasta temporária GRAVÁVEL para o VS Code
        jupyter-env = pkgs.writeShellScriptBin "jupyter-env" ''
          # Cria um diretório temporário único para esta sessão
          export VSCODE_USER_DATA="$(mktemp -d)"
          
          # Prepara a pasta de configurações (User) dentro do diretório temporário
          mkdir -p "$VSCODE_USER_DATA/User"
          cp ${settings} "$VSCODE_USER_DATA/User/settings.json"
          
          # Injeta o Python no PATH e limpa a HOME para isolar kernels
          export PATH="${kernels.pythonFull}/bin:$PATH"
          export HOME="/tmp/nix-jupyter-pure"
          mkdir -p "$HOME"

          # Executa o Codium apontando para a pasta gravável
          exec ${codium-base}/bin/codium --user-data-dir="$VSCODE_USER_DATA" "$@"
        '';

      in {
        # O pacote padrão agora é o nosso script wrapper
        packages.default = jupyter-env;
      }
    );
}