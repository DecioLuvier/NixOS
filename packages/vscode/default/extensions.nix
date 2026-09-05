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
] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
  {
    name = "markdown-preview-enhanced";
    publisher = "shd101wyy";
    version = "0.8.30"; 
    sha256 = "sha256-wtI+W+ZNxXv8WonGDmSt1NxeF8WN8fqPCuMougERxDE="; 
  }
  {
    name = "csv";
    publisher = "repreng";
    version = "1.3.0"; 
    sha256 = "sha256-wrbrArOWHxpjJh8/TQ4YJpz6B3F+WgI5C2bSGUYmfPM="; 
  }
]
