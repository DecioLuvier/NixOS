{
  description = "Jupyter Notebook server para Pesquisa-IFRS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          jupyter
          ipykernel
          numpy
          pandas
          matplotlib
          torch
          torchvision
          datasets
          tqdm
          onnx
          onnxruntime
          onnxsim
          codecarbon
        ]);

        jupyter-pesquisa = pkgs.writeShellApplication {
          name = "jupyter-pesquisa";
          runtimeInputs = [ pythonEnv ];
          text = ''
            exec jupyter notebook \
              --no-browser \
              --ip=0.0.0.0 \
              --port=8888 \
              --notebook-dir="''${NOTEBOOK_DIR:-$HOME/GitHub/Pesquisa-IFRS}"
          '';
        };
      in
      {
        packages.default = jupyter-pesquisa;
        apps.default = flake-utils.lib.mkApp { drv = jupyter-pesquisa; };
      });
}
