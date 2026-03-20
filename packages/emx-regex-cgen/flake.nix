{
  description = "emx-regex-cgen";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    src = {
      url = "github:emmtrix/emx-regex-cgen/v0.2.0";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        py = pkgs.python3Packages;
      in {
        packages.default = py.buildPythonPackage {
          pname = "emx-regex-cgen";
          version = "0.2.0";

          format = "pyproject";
          inherit src;

          nativeBuildInputs = with py; [
            setuptools
            setuptools-scm
            wheel
            pip
          ];

          preBuild = ''
            export PYTHONPATH=$PWD:$PYTHONPATH
          '';

          doCheck = false;
        };
      }
    );
}