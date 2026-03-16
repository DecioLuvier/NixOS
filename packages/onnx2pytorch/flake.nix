{
  description = "Pacote onnx2pytorch isolado";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.python3Packages.buildPythonPackage rec {
          pname = "onnx2pytorch";
          version = "0.4.1";
          
          # Correção para o erro de 'format' no Python 3.13
          pyproject = true;

          src = pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-+TX2sWL8LbQRG44pSNyiP15pjaCopQoXcSmcCHVL7PM=";
          };

          # Define o sistema de build explicitamente
          nativeBuildInputs = with pkgs.python3Packages; [
            setuptools
            wheel
            torchvision
          ];

          doCheck = false;

          propagatedBuildInputs = with pkgs.python3Packages; [ 
            torch 
            onnx 
          ];
        };
      }
    );
}
