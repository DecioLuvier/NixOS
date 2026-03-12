{ pkgs ? import <nixpkgs> {} }:

let
  pythonEnv = pkgs.python3.withPackages (p: with p; [
    ipykernel
    notebook
    torch
    torchvision
    tqdm
    matplotlib
    torchinfo
    onnxscript
    onnxruntime
  ]);

in pkgs.mkShell {
  packages = [
    pkgs.vscodium
    pythonEnv
  ];

  shellHook = ''
    python -m ipykernel install --user \
      --name nix-ml \
      --display-name "Python (nix-ml)" \
      2>/dev/null || true
  '';
}