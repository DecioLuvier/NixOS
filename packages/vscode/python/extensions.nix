{ inputs, system }:

let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };
in
with pkgs.vscode-extensions; [
  ms-python.python
  ms-python.vscode-pylance
  ms-toolsai.jupyter
  dracula-theme.theme-dracula
]
