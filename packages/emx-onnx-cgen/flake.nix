{
  description = "emx-onnx-cgen via GitHub (fixed build)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    emx-onnx-cgen-src = {
      url = "github:emmtrix/emx-onnx-cgen/v1.2.0";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, emx-onnx-cgen-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        py = pkgs.python3Packages;
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

          patchPhase = ''
            sed -i \
              -e 's/build-backend = "packaging_backend"/build-backend = "setuptools.build_meta"/' \
              -e '/backend-path/d' \
              pyproject.toml
          '';

          propagatedBuildInputs = with py; [
            emx-regex-cgen
            jinja2
            numpy
            onnx
            onnxruntime
            protobuf
          ];

          doCheck = false;
        };
      }
    );
}