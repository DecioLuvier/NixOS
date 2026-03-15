{ pkgs }:

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
  ]);
in {
  inherit pythonFull;
}