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
in
{
  packages = [
    pythonFull
    pythonMini
  ];

  shellHook = ''
    ${pythonFull.interpreter} -m ipykernel install --prefix "${self}" --name pyfull --display-name "Python (Full)"
    ${pythonMini.interpreter} -m ipykernel install --prefix "${self}" --name pymini --display-name "Python (Mini)"
  '';
}
