{
  description = "codecarbon 3.2.6 (simple nix package)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        py = pkgs.python3Packages;
      in
      {
        packages.default = py.buildPythonPackage {
          pname = "codecarbon";
          version = "3.2.6";

          format = "pyproject";

          src = pkgs.fetchFromGitHub {
            owner = "mlco2";
            repo = "codecarbon";
            rev = "v3.2.6";
            hash = "sha256-Nzt+CKXnv6zvWKsFD7duguVj0AA4eWZgFUlBdIEujD8="; 
          };

          nativeBuildInputs = with py; [
            setuptools
            wheel
          ];

          propagatedBuildInputs = with py; [
            arrow
            authlib
            click
            pandas
            prometheus-client
            psutil
            py-cpuinfo
            pydantic
            nvidia-ml-py
            rapidfuzz
            requests
            questionary
            rich
            typer
            pycountry
          ];

          doCheck = false;

          pythonImportsCheck = [ "codecarbon" ];
        };
      });
}