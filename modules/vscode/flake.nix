{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    code-carbon.url = "path:../../packages/code-carbon";
    emx-onnx-cgen.url = "path:../../packages/emx-onnx-cgen";
    onnx2pytorch.url = "path:../../packages/onnx2pytorch";

  };

  outputs = { self, nixpkgs, flake-utils, code-carbon, emx-onnx-cgen, onnx2pytorch, onnx2torch }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

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

            exec ${codium-base}/bin/codium --user-data-dir="$VSCODE_USER_DATA" /home/luvier/NixOS "$@"
          '';
      in {
        packages = {
          python = mkCodium {
            kernels = import ./python/kernels.nix {
              inherit pkgs;
              code-carbon = code-carbon.packages.${system}.default;
              onnx2pytorch = onnx2pytorch.packages.${system}.default;
              emx-onnx-cgen = emx-onnx-cgen.packages.${system}.default;
              onnx2torch = onnx2torch.packages.${system}.default;
            };
            settings = import ./python/settings.nix { inherit pkgs; };
            extensions = import ./python/extensions.nix { inherit pkgs; };
          };

          c = mkCodium {
            kernels = import ./c/kernels.nix { inherit pkgs; };
            settings = import ./c/settings.nix { inherit pkgs; };
            extensions = import ./c/extensions.nix { inherit pkgs; };
          };

          nix = mkCodium {
            kernels = import ./nix/kernels.nix { inherit pkgs; };
            settings = import ./nix/settings.nix { inherit pkgs; };
            extensions = import ./nix/extensions.nix { inherit pkgs; };
          };

          default = self.packages.${system}.nix;
        };
      }
    );
}