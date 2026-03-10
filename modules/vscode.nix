{ config, pkgs, ... }:

{
  config = {

    environment.systemPackages = [
      pkgs.vscodium
    ];

  home-manager.sharedModules = [
    ({ pkgs, ... }: {

      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;

        extensions = with pkgs.vscode-extensions; [
          jnoortheen.nix-ide
        ];

        userSettings = {
          "editor.stickyScroll.enabled" = false;
          "editor.minimap.enabled" = false;
          "git.enabled" = false;
          "explorer.confirmDelete" = false;
        };
      };

    })
  ];

  };
}