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
    ../../../modules/alacritty.nix
  ];

  time.timeZone = "America/Sao_Paulo";

  fonts = {
    enableDefaultPackages = true;
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

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following
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
        ags
        gjs
        gtk3
        gtk4
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