{
  description = "Codium + Jupyter com kernels Full/Mini usando $out";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        kernels = import ./kernels.nix {  };
        extensions = import ./extensions.nix {  };
        settings = import ./settings.nix { };

        codium = pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = extensions;
        };

        codiumDataDir = "${toString ./.}/codium-data";
        codiumExtensionsDir = "${toString ./.}/codium-extensions";

      in {
        apps.x86_64-linux.codium-jupyter = {
          type = "app";
          program = "${pkgs.stdenv.shell} -c ''
            mkdir -p ${codiumDataDir} ${codiumExtensionsDir}
            ln -sf ${settings} ${codiumDataDir}/settings.json

            exec ${codium}/bin/codium \
              --user-data-dir ${codiumDataDir} \
              --extensions-dir ${codiumExtensionsDir} \
              \"$@\"
          ''";
        };
      }
    );
}