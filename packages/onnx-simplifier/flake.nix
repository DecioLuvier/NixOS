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
          pname = "onnx-simplifier";
          version = "0.4.36";
          format = "setuptools";

          src = pkgs.fetchurl {
            url = "https://files.pythonhosted.org/packages/source/o/onnx-simplifier/onnx-simplifier-${version}.tar.gz";
            hash = "sha256-IeXpgIe3WwbV0SS/VFZM6YIDJqgwUtUZE6hkCS5INhg=";
          };

          nativeBuildInputs = with py; [ setuptools wheel ];

          propagatedBuildInputs = with py; [ onnx onnxruntime rich ];

          doCheck = false;
        };
      });
}
