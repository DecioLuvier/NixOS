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
          pname = "safetensors";
          version = "0.5.3";
          format = "wheel";

          src = pkgs.fetchPypi {
            pname = "safetensors";
            inherit version;
            format = "wheel";
            dist = "cp313";
            python = "cp313";
            abi = "cp313";
            platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
            hash = "sha256-qG4IWiuR2TZvJXDRCY5r0z5p2F10EuQraBPjHTgBCWA=";
          };

          doCheck = false;
        };
      });
}
