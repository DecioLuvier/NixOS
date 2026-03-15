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
in {
  inherit pythonFull pythonData;
}
