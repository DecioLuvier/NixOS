{ pkgs, emx-onnx-cgen, onnx2c, onnx2pytorch }:

let
  python-env = pkgs.buildEnv {
    name = "python-env";
    paths = [
      pkgs.gcc
      pkgs.perf
      (pkgs.python3.withPackages (p: [
        p.ipykernel
        p.notebook
        p.pip
        p.setuptools
        p.wheel
        #p.torch
        #p.torchvision
        p.tqdm
        p.matplotlib
        #p.torchinfo
        p.onnxscript
        p.onnxruntime
        p.tensorflow
        emx-onnx-cgen
        #onnx2pytorch
      ]))
    ];
    ignoreCollisions = true;
  };

in
  "${python-env}/bin"
