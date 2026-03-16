{ pkgs, onnx2c, ... }:

let
  pythonFull = pkgs.python3.withPackages (p: with p; [
    ipykernel
    notebook
    pip
    setuptools
    wheel
    torch
    torchvision
    tqdm
    matplotlib
    torchinfo
    onnxscript
    onnxruntime
    emx-onnx-cgen
  ]);

  pythonData = pkgs.python3.withPackages (p: with p; [
    ipykernel
    notebook
    pandas
    numpy
    scipy
    seaborn
    scikit-learn
    matplotlib
  ]);
in
"${pkgs.gcc}/bin:${pythonFull}/bin:${pythonData}/bin:${onnx2c}/bin"