{ pkgs, onnx2c, onnx2pytorch, emx-pytorch-cgen, ... }:

let
  pythonFull = pkgs.python3.withPackages (p: [
    p.ipykernel
    p.notebook
    p.pip
    p.setuptools
    p.wheel
    p.torch
    p.torchvision
    p.tqdm
    p.matplotlib
    p.torchinfo
    p.onnxscript
    p.onnxruntime
    emx-pytorch-cgen
    onnx2pytorch
  ]);
in
"${pkgs.gcc}/bin:${pythonFull}/bin:${onnx2c}/bin"