{ pkgs, code-carbon, emx-onnx-cgen }:

let
  python-env = pkgs.buildEnv {
    name = "python-env";
    paths = [
      pkgs.gcc
      pkgs.perf
      pkgs.flamegraph
      pkgs.clang
      emx-onnx-cgen
      code-carbon
      (pkgs.python313.withPackages (p: [
        p.ipykernel
        p.notebook
        p.tensorflow
        p.keras
        p.sympy
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
      ]))
    ];
    ignoreCollisions = true;
  };

in
  "${python-env}/bin"
