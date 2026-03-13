{
  description = "Codium Jupyter devshell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        settings   = import ./settings.nix   { inherit pkgs self; };
        extensions = import ./extensions.nix { inherit pkgs; };
        kernels    = import ./kernels.nix    { inherit pkgs self; };

        codium = pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = extensions;
        };

        codium-jupyter = pkgs.writeShellScriptBin "codium-jupyter" ''
          ln -sf ${settings} ${self}/settings.json
          exec ${codium}/bin/codium --user-data-dir ${self} --extensions-dir ${self} "$@"
        '';
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            codium-jupyter
          ] ++ kernels.packages;

          shellHook = kernels.shellHook;
        };
      }
    );
}
