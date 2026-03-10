{ config, pkgs, ... }:

{
  imports = [
    ../../modules/hyprland.nix
    ../../modules/swaybg.nix
    ../../modules/mako.nix
    ../../modules/waybar.nix
    ../../modules/wlogout.nix
    ../../modules/wofi.nix
    ../../modules/vscode.nix
  ];

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "start-hyprland";
      user = "luvier";
    };
  };

  time.timeZone = "America/Sao_Paulo";

  users.users.luvier = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "storage"
    ];
  };

  environment.systemPackages = with pkgs; [
    simulide
  ];

  programs.git = {
    enable = true;
    config = {
      user.name = "decioluvier";
      user.email = "decioluvieriii@gmail.com";
    };
  };
}