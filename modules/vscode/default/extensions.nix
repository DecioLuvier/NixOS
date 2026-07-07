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
    name = "obsidian-md-vsc";
    publisher = "willasm";
    version = "1.0.0"; 
    sha256 = "sha256-VrMy81jlu6zdAZCj54VRrAzWLW+ejKH8hznlMpByBtg="; 
  }
]
