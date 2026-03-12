{ pkgs ? import <nixpkgs> {} }:

let
  pythonEnv = pkgs.python3.withPackages (p: with p; [
    notebook
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
      pythonEnv
    ];

  shellHook = ''
    export JUPYTER_RUNTIME_DIR=$(mktemp -d)
    export JUPYTER_DATA_DIR=$JUPYTER_RUNTIME_DIR
    export JUPYTER_CONFIG_DIR=$JUPYTER_RUNTIME_DIR

    jupyter notebook --no-browser 
  '';
}