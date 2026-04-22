{ pkgs, emx-onnx-cgen, onnx2c, onnx2pytorch }:

let
  python-env = pkgs.buildEnv {
    name = "python-env";
    paths = [
      pkgs.gcc
      pkgs.perf
      pkgs.flamegraph
      pkgs.clang
      emx-onnx-cgen
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
        emx-onnx-cgen
      ]))
    ];
    ignoreCollisions = true;
  };

in
  "${python-env}/bin"
