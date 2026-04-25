{ pkgs, emx-onnx-cgen, onnx2c, onnx2pytorch }:

let
  nix-env = pkgs.buildEnv {
    name = "nix-env";
    paths = [

    ];
    ignoreCollisions = true;
  };

in
  "${nix-env}/bin"
