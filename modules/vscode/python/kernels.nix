{ pkgs, code-carbon, emx-onnx-cgen, onnx2pytorch, onnx2torch }:

let
  pkgs' = import pkgs.path {
    system = pkgs.stdenv.hostPlatform.system;
    overlays = [
      (final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (py-final: py-prev: {
            torch = py-prev.torch.override {
              triton = py-prev.triton-no-cuda;
              rocmSupport = true;
            };
          })
        ];
      })
    ];
  };

  python-env = pkgs'.buildEnv {
    name = "python-env";
    paths = [
      pkgs'.gcc
      pkgs'.perf
      pkgs'.flamegraph
      pkgs'.clang
      emx-onnx-cgen
      (pkgs'.python313.withPackages (p: [
        p.ipykernel
        p.notebook
        p.tensorflow
        p.keras
        p.sympy
        p.torchao
        p.tqdm
        p.torchinfo
        p.torch
        p.matplotlib
        p.pandas
        p.numpy
        p.torchvision
        p.onnxconverter-common
        p.onnxscript
        code-carbon
        onnx2pytorch
      ]))
    ];
    ignoreCollisions = true;
  };

in
  "${python-env}/bin"