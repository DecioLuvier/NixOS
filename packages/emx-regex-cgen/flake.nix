{
  description = "emx-regex-cgen";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    regex-src = {
      url = "github:emmtrix/emx-regex-cgen/v0.2.0";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
        py = pkgs.python3Packages;
      in {
        packages.default = py.buildPythonPackage {
          pname = "emx-regex-cgen";
          version = "0.2.0";

          format = "pyproject";
          
          src = inputs.regex-src;

          nativeBuildInputs = with py; [
            setuptools
            setuptools-scm
            wheel
            pip
          ];

          doCheck = false;
        };
      }
    );
}