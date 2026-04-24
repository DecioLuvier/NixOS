{ pkgs }:

with pkgs.vscode-extensions; [
  ms-vscode.cpptools
  ms-vscode.cpptools-extension-pack
  ms-vscode.cmake-tools
  twxs.cmake
  ms-vscode.makefile-tools
]
