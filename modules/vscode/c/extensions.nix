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
  ms-vscode.cpptools
  ms-vscode.cpptools-extension-pack
  ms-vscode.cmake-tools
  twxs.cmake
  ms-vscode.makefile-tools
  dracula-theme.theme-dracula
]