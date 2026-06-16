{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    code-carbon.url = "path:../../packages/code-carbon";
    emx-onnx-cgen.url = "path:../../packages/emx-onnx-cgen";
    onnx2pytorch.url = "path:../../packages/onnx2pytorch";
    onnx2torch.url = "path:../../packages/onnx2torch";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; };

        mkVSCode = { kernels, settings, extensions }:
          let
            vscode-base = pkgs.vscode-with-extensions.override {
              vscode = pkgs.vscode;
              vscodeExtensions = extensions;
            };
          in pkgs.writeShellScriptBin "code" ''
            export HOME="$(mktemp -d)"
            export VSCODE_USER_DATA="$(mktemp -d)"
            export PATH="${pkgs.coreutils}/bin:${kernels}:$PATH"
            mkdir -p "$VSCODE_USER_DATA/User"
            cp ${settings} "$VSCODE_USER_DATA/User/settings.json"
            exec ${vscode-base}/bin/code --user-data-dir="$VSCODE_USER_DATA" /home/luvier/NixOS "$@"
          '';
      in {
        packages = {
          python = mkVSCode {
            kernels = import ./python/kernels.nix { inherit inputs system; };
            settings = import ./python/settings.nix { inherit inputs system; };
            extensions = import ./python/extensions.nix { inherit inputs system; };
          };

          c = mkVSCode {
            kernels = import ./c/kernels.nix { inherit inputs system; };
            settings = import ./c/settings.nix { inherit inputs system; };
            extensions = import ./c/extensions.nix { inherit inputs system; };
          };

          nix = mkVSCode {
            kernels = import ./nix/kernels.nix { inherit inputs system; };
            settings = import ./nix/settings.nix { inherit inputs system; };
            extensions = import ./nix/extensions.nix { inherit inputs system; };
          };

          default = mkVSCode {
            kernels = import ./default/kernels.nix { inherit inputs system; };
            settings = import ./default/settings.nix { inherit inputs system; };
            extensions = import ./default/extensions.nix { inherit inputs system; };
          };
        };
      }
    );
}
