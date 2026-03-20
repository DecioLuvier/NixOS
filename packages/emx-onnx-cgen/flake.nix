{
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
          pname = "emx-onnx-cgen";
          version = "0.4.1";
          
          pyproject = true;

          src = pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-+TX2sWL8LbQRG44pSNyiP15pjaCopQoXcSmcCHVL7PM=";
          };
          
          nativeBuildInputs = with pkgs.python3Packages; [

          ];

          doCheck = false;

          propagatedBuildInputs = with pkgs.python3Packages; [ 

          ];
        };
      }
    );
}
