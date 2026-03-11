{ pkgs ? import <nixpkgs> {} }:

let

  bnn = pkgs.callPackage ../packages/bnn.nix {};

  onnx2c = pkgs.callPackage ../packages/onnx2c.nix {};

  pythonEnv = pkgs.python3.withPackages (p: with p; [
    ipykernel
    jupyterlab
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
    pythonEnv
    onnx2c
    pkgs.gcc
    pkgs.gnumake
    pkgs.cmake
  ];

  shellHook = ''
    jupyter lab --browser="firefox --new-window %s"
  '';
}