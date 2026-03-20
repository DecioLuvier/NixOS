{
  description = "emx-pytorch-cgen CLI via GitHub";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    emx-pytorch-src = {
      url = "github:emmtrix/emx-pytorch-cgen";
      flake = false;
    };
    onnx2pytorch-repo.url = "path:../onnx2pytorch";
  };

  outputs = { self, nixpkgs, emx-pytorch-src, onnx2pytorch-repo, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pythonPackages = pkgs.python3Packages;
      onnx2pytorch = onnx2pytorch-repo.packages.${system}.default;
    in {
      packages.${system}.default = pythonPackages.buildPythonPackage rec {
        pname = "emx-pytorch-cgen";
        version = "0.1.0";
        format = "setuptools"; 

        src = emx-pytorch-src;

        nativeBuildInputs = [
          pythonPackages.setuptools
          pythonPackages.wheel
        ];

        propagatedBuildInputs = [
          pythonPackages.torch
          pythonPackages.jinja2
          pythonPackages.onnx
          onnx2pytorch
        ];

                pythonImportsCheck = [ "codegen_backend" ];

        doCheck = false;
      };
    };
}
