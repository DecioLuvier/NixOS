{
  description = "emx-onnx-cgen - ONNX to generic C generator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        emx-onnx-cgen = pkgs.python3Packages.buildPythonApplication rec {
          pname = "emx-onnx-cgen";
          version = "0.5.0";

          src = pkgs.fetchPypi {
            pname = "emx_onnx_cgen";
            inherit version;
            sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };

          propagatedBuildInputs = with pkgs.python3Packages; [
            numpy
            onnx
            jinja2
          ];

          doCheck = false;

          meta = with pkgs.lib; {
            description = "Generate generic C code from ONNX models";
            homepage = "https://github.com/emmtrix/emx-onnx-cgen";
            license = licenses.mit;
            mainProgram = "emx-onnx-cgen";
          };
        };

      in {
        packages.emx-onnx-cgen = emx-onnx-cgen;
        packages.default = emx-onnx-cgen;
      }
    );
}