{ config, pkgs, ... }:

let
  hardwareConfig =
    if builtins.pathExists /mnt/etc/nixos/hardware-configuration.nix then
      /mnt/etc/nixos/hardware-configuration.nix
    else
      /etc/nixos/hardware-configuration.nix;
in
{
  imports = [
    hardwareConfig
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  users.users.luvier = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  environment.systemPackages = with pkgs; [
    git
  ];

  modules.hyprland-desktop = {
    enable = true;
    user = "luvier";
    terminal = "alacritty";
    fileManager = "nautilus";
    wallpaper = "/home/luvier/wallpaper.jpg";
  };

  home-manager.users.luvier = {
    home.stateVersion = "24.11";
  };

  system.stateVersion = "24.11";
}