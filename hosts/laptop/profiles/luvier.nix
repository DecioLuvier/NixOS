{ config, pkgs, ... }:

{
  imports = [
    ../../../modules/hyprland.nix
    ../../../modules/swaybg.nix
    ../../../modules/mako.nix
    ../../../modules/waybar.nix
    ../../../modules/wlogout.nix
    ../../../modules/wofi.nix
    ../../../modules/vscode.nix
  ];

  time.timeZone = "America/Sao_Paulo";

  users.users.luvier = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "storage"
    ];
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "start-hyprland";
      user = "luvier";
    };
  };

  home-manager.users.luvier = {
    home.username = "luvier";
    home.homeDirectory = "/home/luvier";

    home.packages = with pkgs; [
      simulide
      gh
    ];

    programs.git = {
      enable = true;
      extraConfig = {
        user = {
          name = "decioluvier";
          email = "decioluvieriii@gmail.com";
        };
      };
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;

      userSettings = {
        "editor.stickyScroll.enabled" = false;
        "editor.minimap.enabled" = false;
        "git.enabled" = false;
      };
    };

  };
}