{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        onnx2c = pkgs.callPackage ./pkgs/onnx2c.nix {};

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
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            pythonEnv
            onnx2c
            gcc
            gnumake
            cmake
          ];

          shellHook = ''
            jupyter lab
          '';
        };
      }
    );
}