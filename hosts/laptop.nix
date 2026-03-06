{ config, pkgs, ... }:

{

  imports = [
    ./hardware-configuration.nix 
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true; 

  networking.hostName = "nixos"; 
  networking.networkmanager.enable = true; 

  home-manager.users.luvier.home.stateVersion = "24.11";
  system.stateVersion = "24.11";

  # -----------------------------
  # User configuration
  # -----------------------------

  users.users.luvier = {
    isNormalUser = true;  # Create a regular user
    extraGroups = [
      "wheel"             # Allows sudo access
      "networkmanager"    # Allows controlling network connections
    ];
  };

  # -----------------------------
  # Login manager
  # -----------------------------
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "start-hyprland";   # Command used to start the desktop session
      user = "luvier";              # User that will run the session
    };
  };

  # -----------------------------
  # System packages
  # -----------------------------
  environment.systemPackages = with pkgs; [
    git
    xdg-utils
    grim
    slurp
  ];

  # -----------------------------
  # Cursor configuration
  # -----------------------------

  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };

  # -----------------------------
  # System Configuration
  # -----------------------------
  modules = {
    hyprland = {
      terminal = "alacritty";
      fileManager = "nautilus";
      appLauncher = "wofi";
      browser = "brave";

      keyboardLayout = "br";
      keyboardVariant = "abnt2";
    };

    hyprpaper = {
      wallpaper = "/home/wallpaper.jpg";
    };
  };
}