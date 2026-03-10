{ pkgs ? import <nixpkgs> {} }:

let
  onnx2c = pkgs.callPackage ../overlays/onnx2c.nix {};

  pythonEnv = pkgs.python3.withPackages (p: with p; [
    ipykernel
    jupyterlab
    torch
    torchvision
    tqdm
    matplotlib
    torchinfo
    onnxscript
  ]);
in

pkgs.mkShell {
  packages = [
    pythonEnv
    onnx2c
    pkgs.gcc
    pkgs.gnumake
    pkgs.cmake
  ];

  shellHook = ''
    jupyter lab --no-browser
  '';
}