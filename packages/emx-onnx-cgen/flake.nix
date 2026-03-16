{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    emx-src = {
      url = "github:emmtrix/emx-onnx-cgen";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, emx-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.python3Packages.buildPythonPackage {
          pname = "emx-onnx-cgen";
          version = "2026-03-04";
          src = emx-src;

          pyproject = false;

          nativeBuildInputs = with pkgs.python3Packages; [
            setuptools
            wheel
          ];

          propagatedBuildInputs = with pkgs.python3Packages; [
            onnx
            numpy
          ];

          doCheck = false;

          meta = with pkgs.lib; {
            description = "Deterministic ONNX-to-C compiler";
            homepage = "https://github.com";
            license = licenses.asl20;
          };
        };
      }
    );
}
