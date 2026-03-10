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
    home = {
      username = "luvier";
      homeDirectory = "/home/luvier";
      stateVersion = "24.11";
      packages = with pkgs; [
        simulide
        gh
        github-desktop
      ];
    };

    programs.git = {
      enable = true;
      extraConfig = {
        user = {
          name = "decioluvier";
          email = "decioluvieriii@gmail.com";
        };
      };
    };
  };
}