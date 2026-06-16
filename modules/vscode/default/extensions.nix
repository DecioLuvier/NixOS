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
  ms-vscode-remote.remote-ssh
  dracula-theme.theme-dracula
  jnoortheen.nix-ide
]