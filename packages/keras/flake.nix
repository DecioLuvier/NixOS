{
  description = "keras from github";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    keras-src = {
      url = "github:keras-team/keras";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, keras-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        py = pkgs.python310Packages;
      in {
        packages.keras = py.buildPythonPackage rec {
          pname = "keras";
          version = "git";

          format = "pyproject";
          src = keras-src;

          nativeBuildInputs = with py; [
            setuptools
            wheel
            pip
          ];

          propagatedBuildInputs = with py; [
            numpy
            h5py
            packaging
          ];

          doCheck = false;
        };

        packages.default = self.packages.${system}.keras;
      }
    );
}