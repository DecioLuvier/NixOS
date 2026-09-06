{ config, pkgs, lib, vscode, ... }:

{
  # ── Nix ─────────────────────────────────────────────────────────────────────
  nix.settings = {
    warn-dirty            = false;
    experimental-features = [ "nix-command" "flakes" ];
  };

  system.stateVersion        = "24.11";
  nixpkgs.config.allowUnfree = true;

  # ── Boot ────────────────────────────────────────────────────────────────────
  # GRUB (wallpaper, generations, boot sem Hyprland, BIOS): packages/MikuBoot/flake.nix
  boot = {
    tmp.cleanOnBoot = true;
    plymouth.enable = false;
  };

  # ── Rede ────────────────────────────────────────────────────────────────────
  networking = {
    hostName              = "laptop";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Sao_Paulo";

  # ── Utilizador ──────────────────────────────────────────────────────────────
  users.users.luvier = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "networkmanager" "storage" ];
  };

  # ── Ambiente ────────────────────────────────────────────────────────────────
  documentation = {
    enable       = false;
    doc.enable   = false;
    info.enable  = false;
    man.enable   = false;
    nixos.enable = false;
  };

  environment = {
    defaultPackages = [ ];
  };

  programs = {
    command-not-found.enable = true;
    fish.generateCompletions = true;

    nix-ld = {
      enable = true;
      libraries = with pkgs; [ stdenv.cc.cc.lib zlib ];
    };
  };

  # ── Hardware ────────────────────────────────────────────────────────────────
  hardware.bluetooth = {
    enable      = true;
    powerOnBoot = true;
  };

  security.rtkit.enable = true;

  # ── Serviços ────────────────────────────────────────────────────────────────
  services = {
    avahi            = { enable = true; nssmdns4 = true; openFirewall = true; };
    blueman.enable   = true;
    logrotate.enable = false;
    upower.enable    = true;
    udisks2.enable   = true;
    gvfs.enable      = true;

    gnome.gnome-keyring.enable = true;

    greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.hyprland}/bin/start-hyprland";
        user = "luvier";
      };
    };

    pipewire = {
      enable             = true;
      alsa.enable        = true;
      alsa.support32Bit  = true;
      pulse.enable       = true;
      jack.enable        = true;
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
        USB_AUTOSUSPEND             = 1;
        RUNTIME_PM_ON_AC            = "on";
        RUNTIME_PM_ON_BAT           = "auto";
        SATA_LINKPWR_ON_AC          = "med_power_with_dipm";
        SATA_LINKPWR_ON_BAT         = "min_power";
        SOUND_POWER_SAVE_ON_AC      = 0;
        SOUND_POWER_SAVE_ON_BAT     = 1;
      };
    };
  };

  # ── Home Manager ────────────────────────────────────────────────────────────
  home-manager.users.luvier = {
    home = {
      username      = "luvier";
      homeDirectory = "/home/luvier";
      stateVersion  = "24.11";
      packages = with pkgs; [
        github-desktop
        bun
        onlyoffice-desktopeditors
        btop
        claude-code
        gnumake
        unrar
        node-gyp
        zip
        unzip
        gcc
        nodejs
        jc
      ] ++ [
        vscode.packages.x86_64-linux.default
        vscode.packages.x86_64-linux.python
        vscode.packages.x86_64-linux.c
        vscode.packages.x86_64-linux.js
      ];
    };

    gtk = {
      enable = true;
      iconTheme = { name = "Adwaita"; package = pkgs.adwaita-icon-theme; };
    };

    programs.command-not-found.enable = false;

    programs.git = {
      enable = true;
      settings.user = { name = "decioluvier"; email = "decioluvieriii@gmail.com"; };
    };
  };
}
