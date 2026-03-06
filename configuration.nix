{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  users.users.luvier = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  modules.hyprland-desktop = {
    enable = true;
    user = "luvier";
    terminal = "alacritty";
    fileManager = "nautilus";
    wallpaper = "/home/luvier/wallpaper.jpg";
  };

  system.stateVersion = "24.11";
}