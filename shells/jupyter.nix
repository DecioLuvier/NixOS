{ pkgs ? import <nixpkgs> {} }:

let
  pyFull = pkgs.python3.withPackages (p: with p; [
    notebook
    ipykernel
    torch
    torchvision
    tqdm
    matplotlib
    torchinfo
    onnxscript
    onnxruntime
  ]);
in

pkgs.mkShell {
  buildInputs = [
    pyFull
  ];

  shellHook = ''
    ${pyFull.interpreter} -m ipykernel install --user --name pyfull --display-name "Python (Full)" 
  '';
}