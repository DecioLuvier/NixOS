{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
  ];

  hardware.enableAllHardware = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";

  nixpkgs.config = {
    allowUnfree = true;
  };

  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  
  networking = {
    hostName = "desktop";
    networkmanager.enable = true;
  };

  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  environment = {
    defaultPackages = [ ];
    stub-ld.enable = false;
  };

  programs = {
    command-not-found.enable = true;
    fish.generateCompletions = true;
  };

  services = {
    logrotate.enable = false;
    gnome.gnome-keyring.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    pipewire.enable = true;
  };
}