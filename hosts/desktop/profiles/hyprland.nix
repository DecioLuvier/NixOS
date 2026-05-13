{ config, pkgs, ... }:

{
  imports = [
    ../../../modules/hyprland.nix
    ../../../modules/swaybg.nix
    ../../../modules/mako.nix
    ../../../modules/waybar.nix
    ../../../modules/wlogout.nix
    ../../../modules/wofi.nix
    ../../../modules/alacritty.nix
  ];

  time.timeZone = "America/Sao_Paulo";

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      adwaita-icon-theme
      hicolor-icon-theme
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "DejaVu Sans" ];
      };
    };
  };
    
  users.users.luvier = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "storage"
    ];
  };
  
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  }; 
  services.blueman.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "start-hyprland";
      user = "luvier";
    };
  };

  services.upower.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; 
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.pipewire.wireplumber.enable = true;
  
  home-manager.users.luvier = {
    home = {
      username = "luvier";
      homeDirectory = "/home/luvier";
      stateVersion = "24.11";
      packages = with pkgs; [
        simulide
        github-desktop
        melonds
        brightnessctl
        btop
        gcc
        discord
        nodejs
        jc
      ];
    };

    
    gtk = {
      enable = true;
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
    };

    programs.command-not-found.enable = false;

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