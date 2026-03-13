{
  description = "VSCode dev environment only";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system}.vscode = pkgs.mkShell {
      packages = [ pkgs.vscodium ];

    };

    homeManagerModules.default = { pkgs, ... }: {
      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;

        extensions = with pkgs.vscode-extensions; [
          ms-python.python
          ms-toolsai.jupyter
        ];

        userSettings = {
          "editor.stickyScroll.enabled" = false;
          "editor.minimap.enabled" = false;
          "git.enabled" = false;
          "explorer.confirmDelete" = false;

          "jupyter.kernels.excludePythonEnvironments" = [".*"];

          "jupyter.kernels.trusted" = [
            "${builtins.getEnv "HOME"}/.local/share/jupyter/kernels/batata/kernel.json"
            "${builtins.getEnv "HOME"}/.local/share/jupyter/kernels/pymini/kernel.json"
          ];
        };
      };
    };
  };
}