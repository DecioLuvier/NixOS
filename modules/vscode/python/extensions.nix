{ inputs, system }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
with pkgs.vscode-extensions; [
  ms-python.python
  ms-python.vscode-pylance
  ms-toolsai.jupyter
  dracula-theme.theme-dracula
]
