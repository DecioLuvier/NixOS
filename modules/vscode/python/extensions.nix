{ pkgs }:

with pkgs.vscode-extensions; [
  ms-python.python
  ms-python.vscode-pylance
  ms-toolsai.jupyter
  dracula-theme.theme-dracula
]