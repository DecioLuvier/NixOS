{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    jupyter.url = "github:kirelagin/jupyter.nix";
  };

  outputs = { self, nixpkgs, flake-utils, jupyter }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = {
        jupyter = jupyter.lib.makeJupyterLab {
          pkgs = pkgs;

          extraBuildInputs = [
            pkgs.gcc
            pkgs.gnumake
            pkgs.cmake
            pkgs.valgrind
          ];

          kernels = {
            "python3".ipykernel = {
              packages = pp: with pp; [
                torch
                torchvision
                tqdm
                matplotlib
                torchinfo
                onnxscript
                onnxruntime
                onnx2c
              ];
              withPlotly = true;
            };
          };
        };
      };
    });
}