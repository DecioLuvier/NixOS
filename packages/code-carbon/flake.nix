{
  description = "codecarbon 3.2.6 — carbon emissions tracker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python312;

        codecarbon = python.pkgs.buildPythonPackage rec {
          pname   = "codecarbon";
          version = "3.2.6";
          format  = "pyproject";

          src = pkgs.fetchPypi {
            inherit pname version;
            sha256 = "sha256-RGQ921cfz13jbBo15/2fDMi9K7Eky5e9vS3W8H6mv8k=";
          };

          nativeBuildInputs = with python.pkgs; [
            setuptools
            wheel
          ];

          propagatedBuildInputs = with python.pkgs; [
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

          meta = {
            description  = "Track and reduce CO2 emissions from machine learning";
            homepage     = "https://codecarbon.io/";
            changelog    = "https://github.com/mlco2/codecarbon/releases/tag/v${version}";
            license      = pkgs.lib.licenses.mit;
            maintainers  = [ ];
          };
        };

        pythonEnv = python.withPackages (ps: [
          codecarbon
          ps.numpy
          ps.pandas
          ps.tqdm
        ]);

      in {
        packages = {
          inherit codecarbon;
          default = codecarbon;
        };

        devShells.default = pkgs.mkShell {
          packages = [ pythonEnv ];

          shellHook = ''
            echo "codecarbon ${codecarbon.version} available"
            echo "Python: $(python --version)"
          '';
        };
      });
}
