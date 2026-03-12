{
  description = "Dev env with single Jupyter kernel filtered by path";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    pythonEnv = pkgs.python3.withPackages (p: with p; [
      ipykernel
      torch
      torchvision
      tqdm
      matplotlib
      torchinfo
      onnxscript
      onnxruntime
    ]);
  in {

    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pythonEnv
        pkgs.vscodium
      ];

      shellHook = ''
        # Caminho onde o kernel será registrado
        KERNEL_DIR="$HOME/.local/share/jupyter/kernels/nix-python"

        # Registra o kernel somente se ainda não estiver registrado
        if [ ! -d "$KERNEL_DIR" ]; then
          python -m ipykernel install \
            --user \
            --name nix-python \
            --display-name "Python (nix)"
        fi
      '';
    };

    homeManagerModules.default = { pkgs, ... }: {

      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;

        extensions = with pkgs.vscode-extensions; [
          jnoortheen.nix-ide
          ms-python.python
          ms-toolsai.jupyter
        ];

        userSettings = {

          "editor.stickyScroll.enabled" = false;
          "editor.minimap.enabled" = false;
          "git.enabled" = false;
          "explorer.confirmDelete" = false;

          # Esconde todos os ambientes Python que não queremos
          "jupyter.kernels.excludePythonEnvironments" = [
            ".*"
          ];

          # Mostra apenas o kernel do pythonEnv registrado
          "jupyter.kernels.filter" = [
            {
              path = "${pythonEnv}/bin/python";
            }
          ];
        };
      };

    };

  };
}