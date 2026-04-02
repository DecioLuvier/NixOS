{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    emx-onnx-cgen-src = {
      url = "github:emmtrix/emx-onnx-cgen/v1.2.0";
      flake = false;
    };

    emx-regex-cgen = {
      url = "path:../emx-regex-cgen";
    };
  };

  outputs = { self, nixpkgs, flake-utils, emx-onnx-cgen-src, emx-regex-cgen, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        py = pkgs.python3Packages;

        emxRegexPkg = emx-regex-cgen.packages.${system}.default;

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
            emxRegexPkg
            py.jinja2
            py.numpy
            py.onnx
            py.onnxruntime
            py.protobuf
          ];

          preBuild = ''
            export PYTHONPATH=${emxRegexPkg}/${py.python.sitePackages}:$PYTHONPATH
          '';

          doCheck = false;
        };
      });
}