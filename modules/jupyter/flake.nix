{
  description = "Dev env with two Jupyter kernels filtered by path";

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

    pythonMini = pkgs.python3.withPackages (p: with p; [
      ipykernel
      tqdm
      matplotlib
    ]);
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pythonEnv
        pythonMini
        pkgs.vscodium
      ];

      shellHook = ''
        ${pythonEnv.interpreter} -m ipykernel install --user --name pyfull --display-name "Python (Full)"
        ${pythonMini.interpreter} -m ipykernel install --user --name pymini --display-name "Python (Mini)"

      '';
    };

    homeManagerModules.default = { pkgs, ... }: {

      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;

        extensions = with pkgs.vscode-extensions; [
          ms-python.python
          ms-toolsai.jupyter
        ];

        userSettings = {
          "editor.stickyScroll.enabled" = false;
          "editor.minimap.enabled" = false;
          "git.enabled" = false;
          "explorer.confirmDelete" = false;

          "jupyter.kernels.excludePythonEnvironments" = [".*"];

          "jupyter.kernels.trusted" = [
            "${builtins.getEnv "HOME"}/.local/share/jupyter/kernels/pyfull/kernel.json"
            "${builtins.getEnv "HOME"}/.local/share/jupyter/kernels/pymini/kernel.json"
          ];
        };
      };

    };
  };
}