{
  description = "VSCode profiles";

  inputs = {
    nixpkgs.url    = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; config.allowUnfree = true; };

        makeCode = { name, kernels, settings, extensions }:
          let
            vscode-base = pkgs.vscode-with-extensions.override {
              vscode = pkgs.vscode;
              vscodeExtensions = extensions;
            };
          in
          pkgs.writeShellScriptBin name ''
            export HOME="$(mktemp -d)"
            export VSCODE_USER_DATA="$(mktemp -d)"
            export PATH="${pkgs.coreutils}/bin:${kernels}:$PATH"
            mkdir -p "$VSCODE_USER_DATA/User"
            cp ${settings} "$VSCODE_USER_DATA/User/settings.json"
            exec ${vscode-base}/bin/code --user-data-dir="$VSCODE_USER_DATA" "$@"
          '';

      in {
        packages = {
          default = makeCode {
            name       = "code";
            kernels    = import ./default/kernels.nix    { inherit inputs system; };
            settings   = import ./default/settings.nix   { inherit inputs system; };
            extensions = import ./default/extensions.nix { inherit inputs system; };
          };
          python = makeCode {
            name       = "code-python";
            kernels    = import ./python/kernels.nix    { inherit inputs system; };
            settings   = import ./python/settings.nix   { inherit inputs system; };
            extensions = import ./python/extensions.nix { inherit inputs system; };
          };
          c = makeCode {
            name       = "code-c";
            kernels    = import ./c/kernels.nix    { inherit inputs system; };
            settings   = import ./c/settings.nix   { inherit inputs system; };
            extensions = import ./c/extensions.nix { inherit inputs system; };
          };
          js = makeCode {
            name       = "code-js";
            kernels    = import ./js/kernels.nix    { inherit inputs system; };
            settings   = import ./js/settings.nix   { inherit inputs system; };
            extensions = import ./js/extensions.nix { inherit inputs system; };
          };
        };
      }
    );
}
