{ inputs, system }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
with pkgs.vscode-extensions; [
]