nix

{
  description = "emx-pytorch-cgen CLI local";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    onnx2pytorch-repo.url = "path:../onnx2pytorch";
  };

  outputs = { self, nixpkgs, onnx2pytorch-repo, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      python = pkgs.python3;
      
      onnx2pytorch = onnx2pytorch-repo.packages.${system}.default;
    in {
      packages.${system}.default = python.pkgs.buildPythonPackage rec {
        pname = "emx-pytorch-cgen";
        version = "0.1.0";
        pyproject = true;

        src = ./.;

        nativeBuildInputs = with python.pkgs; [
          setuptools
          wheel
        ];

        propagatedBuildInputs = with python.pkgs; [
          torch
          jinja2
          onnx
          onnx2pytorch
        ];


        doCheck = false;
      };
    };
}