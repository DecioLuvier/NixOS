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
          pname = "onnx2pytorch";
          version = "0.4.1";

          format = "pyproject";

          src = pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-+TX2sWL8LbQRG44pSNyiP15pjaCopQoXcSmcCHVL7PM=";
          };

          nativeBuildInputs = [
            py.setuptools
            py.wheel
            py.onnx
            py.torchvision
          ];

          pythonImportsCheck = [ "onnx2pytorch" ];
          doCheck = false;
        };
      });
}