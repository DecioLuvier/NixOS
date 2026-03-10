{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
  home.stateVersion = "24.11";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "laptop";
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
    command-not-found.enable = false;
    fish.generateCompletions = false;
  };

  services = {
    logrotate.enable = false;

    udisks2.enable = true;
    gvfs.enable = true;
    pipewire.enable = true;

    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_MAX_PERF_ON_AC = 100;
        CPU_MAX_PERF_ON_BAT = 40;

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;

        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";

        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";

        USB_AUTOSUSPEND = 1;

        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";

        SATA_LINKPWR_ON_AC = "med_power_with_dipm";
        SATA_LINKPWR_ON_BAT = "min_power";

        SOUND_POWER_SAVE_ON_AC = 0;
        SOUND_POWER_SAVE_ON_BAT = 1;
      };
    };
  };

  xdg = {
    autostart.enable = false;
    icons.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };
}