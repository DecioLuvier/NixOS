{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    emx-onnx-cgen-src = {
      url = "github:emmtrix/emx-onnx-cgen/v1.2.0";
      flake = false;
    };

    emx_regex_cgen.url = "path:../emx-regex-cgen";
  };

  outputs = { self, nixpkgs, flake-utils, emx-onnx-cgen-src, emx_regex_cgen, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        py = pkgs.python3Packages;

        emxRegex = emx_regex_cgen.packages.${system}.default;

      in {
        packages.default = py.buildPythonPackage rec {
          pname = "emx-onnx-cgen";
          version = "1.2.0";

          format = "pyproject";
          src = emx-onnx-cgen-src;

          nativeBuildInputs = with py; [
            setuptools
            setuptools-scm
            wheel
            pip
          ];

          propagatedBuildInputs = [
            emxRegex
            py.jinja2
            py.numpy
            py.onnx
            py.onnxruntime
            py.protobuf
          ];

          preBuild = ''
            export PYTHONPATH=$PWD:$PYTHONPATH
          '';

          doCheck = false;
        };
      }
    );
}