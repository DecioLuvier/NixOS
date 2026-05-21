{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        py = pkgs.python3Packages;
      in {
        packages.default = py.buildPythonPackage rec {
          pname = "onnx2torch";
          version = "1.5.15";

          format = "pyproject";

          src = pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };

          nativeBuildInputs = [
            py.setuptools
            py.wheel
          ];

          propagatedBuildInputs = [
            py.torch
            py.torchvision
            py.onnx
            py.numpy
          ];

          pythonImportsCheck = [ "onnx2torch" ];

          doCheck = false;
        };
      });
}