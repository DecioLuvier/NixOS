{
  description = "Jupyter dev environment with Python Full/Mini and VSCodium";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        pythonFull = pkgs.python3.withPackages (p: with p; [
          ipykernel
          notebook
          pip
          setuptools
          wheel
          torch
          torchvision
          tqdm
          matplotlib
          torchinfo
          onnxscript
          onnxruntime
        ]);


        pythonMini = pkgs.python3.withPackages (p: with p; [
          ipykernel
          tqdm
          matplotlib
        ]);

        extensions = import ./extensions.nix { inherit pkgs; };

        codium = pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = extensions;
        };

        settings = import ./settings.nix { inherit pkgs pythonFull pythonMini; };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [ codium pythonFull pythonMini ];

          shellHook = ''
            mkdir -p $PWD/.vscode
            cp ${settings} /home/luvier/NixOS/shells/jupyter/.vscode/User/settings.json

            ${pythonFull.interpreter} -m ipykernel install --user --name pyfull --display-name "Python (Full)"
            ${pythonMini.interpreter} -m ipykernel install --user --name pymini --display-name "Python (Mini)"


            codium --user-data-dir=/home/luvier/NixOS/shells/jupyter/.vscode "$PWD"
          '';
        };

      }
    );
}