{ pkgs, lib, ... }:

{
  system.stateVersion        = "24.11";
  nixpkgs.config.allowUnfree = true;

  programs.uwsm.enable = true;

  networking.hosts = {
    "140.82.121.6" = [ "api.github.com" ];
    "140.82.121.3" = [ "github.com" ];
  };

  nix.settings = {
    warn-dirty            = false;
    experimental-features = [ "nix-command" "flakes" ];
  };

  boot = {
    tmp.cleanOnBoot                = true;
    loader.grub.configurationLimit = 5;
    consoleLogLevel               = 0;
    stage2Greeting                = "";
    initrd = {
      systemd.enable          = true;
      verbose                 = false;
      includeDefaultModules   = false;
      kernelModules           = [ "i915" "nvme" "ext4" ];
      availableKernelModules  = [ "i915" "nvme" "ext4" ];
    };
    kernelParams = [
      "quiet"
      "loglevel=3"
      "udev.log_priority=3"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=false"
      "systemd.show_status=false"
      "vt.global_cursor_default=0"
      "nmi_watchdog=0"
    ];
  };

  systemd.settings.Manager = {
    RuntimeWatchdogSec  = "0";
    ShutdownWatchdogSec = "0";
    RebootWatchdogSec   = "0";
    KExecWatchdogSec    = "0";
  };

  networking = {
    hostName              = "laptop";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Sao_Paulo";

  users.users.luvier = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "networkmanager" "storage" ];
  };

  environment.defaultPackages = [ ];

  programs = {
    command-not-found.enable = true;
    fish.generateCompletions = true;
    nix-ld = {
      enable    = true;
      libraries = with pkgs; [ stdenv.cc.cc.lib zlib ];
    };
  };

  hardware.bluetooth = {
    enable      = true;
    powerOnBoot = true;
  };

  security.rtkit.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  services = {
    avahi          = { enable = true; nssmdns4 = true; openFirewall = true; };
    blueman.enable = true;
    upower.enable  = true;
    udisks2.enable = true;
    gvfs.enable    = true;
    logrotate.enable = false;
    gnome.gnome-keyring.enable = true;

    greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.uwsm}/bin/uwsm start -e -D Hyprland hyprland.desktop";
        user    = "luvier";
      };
    };

    pipewire = {
      enable            = true;
      alsa.enable       = true;
      alsa.support32Bit = true;
      pulse.enable      = true;
      jack.enable       = true;
      wireplumber.enable = true;
    };

    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC  = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_MAX_PERF_ON_AC          = 100;
        CPU_MAX_PERF_ON_BAT         = 40;
        CPU_BOOST_ON_AC             = 1;
        CPU_BOOST_ON_BAT            = 0;
        WIFI_PWR_ON_AC              = "off";
        WIFI_PWR_ON_BAT             = "on";
        PCIE_ASPM_ON_AC             = "default";
        PCIE_ASPM_ON_BAT            = "powersupersave";
        USB_AUTOSUSPEND            = 1;
        RUNTIME_PM_ON_AC           = "on";
        RUNTIME_PM_ON_BAT          = "auto";
        SATA_LINKPWR_ON_AC         = "med_power_with_dipm";
        SATA_LINKPWR_ON_BAT        = "min_power";
        SOUND_POWER_SAVE_ON_AC     = 0;
        SOUND_POWER_SAVE_ON_BAT    = 1;
      };
    };
  };

  home-manager.users.luvier = {
    home = {
      username      = "luvier";
      homeDirectory = "/home/luvier";
      stateVersion  = "24.11";
      packages = with pkgs; [
        gh
        brave
        claude-code
        vscode
        onlyoffice-desktopeditors
        btop
        jc
        gnumake
        lazygit
        gcc
        node-gyp
        nodejs
        bun
        zip
        unzip
        unrar
      ];
    };

    gtk = {
      enable    = true;
      iconTheme = { name = "Adwaita"; package = pkgs.adwaita-icon-theme; };
    };

    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user       = { name = "decioluvier"; email = "decioluvieriii@gmail.com"; };
        credential = { "https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential"; };
      };
    };
  };
}
