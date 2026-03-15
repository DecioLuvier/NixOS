{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        kernels = import ./kernels.nix { inherit pkgs; };
        settings = import ./settings.nix { inherit pkgs; };
        extensions = import ./extensions.nix { inherit pkgs; };

        user-settings = pkgs.runCommand "vscodium-settings" {} ''
          mkdir -p $out/User
          cp ${settings} $out/User/settings.json
        '';

        codium-isolated = (pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = extensions;
        }).overrideAttrs (old: {
          makeWrapperArgs = (old.makeWrapperArgs or []) ++ [
            "--prefix PATH : ${pkgs.lib.makeBinPath [ kernels.pythonFull ]}"
            "--add-flags --user-data-dir=${user-settings}"
            "--set HOME /tmp/nix-jupyter-pure"
          ];
        });

      in {
        packages.default = codium-isolated;
      }
    );
}