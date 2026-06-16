{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
  ];

  nix.settings.warn-dirty = false;

  hardware = {
    enableAllHardware = true;

    graphics = {
      enable = true;

      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        rocmPackages.rocm-runtime
      ];
    };

  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";

  nixpkgs.config = {
    allowUnfree = true;
  };

  boot = {
    tmp.cleanOnBoot = true;

    kernelModules = [ "amdgpu" "kfd" ];

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

    variables = {
      ROCM_PATH = "${pkgs.rocmPackages.clr}";
    };
  };

  users.users.luvier.extraGroups = [
    "video"
    "render"
  ];

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