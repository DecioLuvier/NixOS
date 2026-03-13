{ pkgs, self }:

let
  pythonFull = pkgs.python3.withPackages (p: with p; [
    ipykernel
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

  kernelDir = "${self}/kernels"; 
in
{
  packages = [
    pythonFull
    pythonMini
  ];

  shellHook = ''
    mkdir -p ${kernelDir}
    ${pythonFull.interpreter} -m ipykernel install --prefix "${kernelDir}" --display-name "Python (Full)"
    ${pythonMini.interpreter} -m ipykernel install --prefix "${kernelDir}" --display-name "Python (Mini)"
    export JUPYTER_PATH="${kernelDir}:${JUPYTER_PATH}"
  '';
}