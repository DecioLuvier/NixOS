{
  description = "Dev env with Python kernels and VSCode imported";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Importa o flake do VSCode
    flake-vscode.url = "path:./vscode"; 
  };

  outputs = { self, nixpkgs, home-manager, flake-vscode }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    # Python completo
    pythonEnv = pkgs.python3.withPackages (p: with p; [
      ipykernel
      torch
      torchvision
      tqdm
      matplotlib
      torchinfo
      onnxscript
      onnxruntime
    ]);

    # Python mini
    pythonMini = pkgs.python3.withPackages (p: with p; [
      ipykernel
      tqdm
      matplotlib
    ]);
  in {
    # DevShell principal (Python + kernels)
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pythonEnv
        pythonMini
      ];

      shellHook = ''
        ${pythonEnv.interpreter} -m ipykernel install --user --name batata --display-name "Python (Full)"
        ${pythonMini.interpreter} -m ipykernel install --user --name pymini --display-name "Python (Mini)"
      '';
    };

    # Home Manager
    homeManagerModules.default = { pkgs, ... }: {
      # Importa apenas o módulo do VSCode
      imports = [ flake-vscode.homeManagerModules.default { inherit pkgs; } ];
    };
  };
}