{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    onnx2c.url = "path:../../packages/onnx2c";
    onnx2pytorch.url = "path:../../packages/onnx2pytorch";
    emx-pytorch-cgen.url = "path:../../packages/emx-pytorch-cgen";
  };

  outputs = { self, nixpkgs, flake-utils, onnx2c, onnx2pytorch, emx-pytorch-cgen }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        mkCodium = { kernels, settings, extensions }:
          let
            codium-base = pkgs.vscode-with-extensions.override {
              vscode = pkgs.vscodium;
              vscodeExtensions = extensions;
            };
          in pkgs.writeShellScriptBin "codium" ''
            export HOME="$(mktemp -d)"
            export VSCODE_USER_DATA="$(mktemp -d)"

            export PATH="${pkgs.coreutils}/bin:${kernels}:$PATH"

            mkdir -p "$VSCODE_USER_DATA/User"
            cp ${settings} "$VSCODE_USER_DATA/User/settings.json"

            exec ${codium-base}/bin/codium --user-data-dir="$VSCODE_USER_DATA" "$@"
          '';

      in {
        packages = {
          python = mkCodium {
            kernels = import ./python/kernels.nix {
              inherit pkgs;
              onnx2c = onnx2c.packages.${system}.default;
              onnx2pytorch = onnx2pytorch.packages.${system}.default;
              emx-pytorch-cgen = emx-pytorch-cgen.packages.${system}.default;
            };
            settings = import ./python/settings.nix { inherit pkgs; };
            extensions = import ./python/extensions.nix { inherit pkgs; };
          };

          js = mkCodium {
            kernels = import ./js/kernels.nix { inherit pkgs; };
            settings = import ./js/settings.nix { inherit pkgs; };
            extensions = import ./js/extensions.nix { inherit pkgs; };
          };

          default = self.packages.${system}.python;
        };
      }
    );
}