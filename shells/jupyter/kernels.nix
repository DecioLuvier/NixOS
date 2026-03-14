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
pkgs.stdenv.mkDerivation {
  pname = "jupyter-kernels";
  version = "1.0";

  buildInputs = [ pythonFull pythonMini ];

  installPhase = ''
    mkdir -p $out/share/jupyter/kernels

    ${pythonFull.interpreter} -m ipykernel install \
      --prefix $out \
      --name pyfull \
      --display-name "Python (Full)"

    ${pythonMini.interpreter} -m ipykernel install \
      --prefix $out \
      --name pymini \
      --display-name "Python (Mini)"
  '';
}