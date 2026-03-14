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

  pythonMini = pkgs.python3.withPackages (p: with p; [
    ipykernel
    tqdm
    matplotlib
  ]);
in {
  shellHook = ''
    ${pythonFull.interpreter} -m ipykernel install --prefix "$PWD/.kernels" --name pyfull --display-name "Python (Full)"
    ${pythonMini.interpreter} -m ipykernel install --prefix "$PWD/.kernels" --name pymini --display-name "Python (Mini)"
  '';
}