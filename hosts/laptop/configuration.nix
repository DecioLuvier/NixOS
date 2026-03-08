
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
  
  system.stateVersion = "24.11";

  # -----------------------------
  # User configuration
  # -----------------------------
  
  users.users.luvier = {
    isNormalUser = true;  # Create a regular user
    extraGroups = [
      "wheel"             # Allows sudo access
      "networkmanager"    # Allows controlling network connections
      "storage"
    ];
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;


  # -----------------------------
  # System packages
  # -----------------------------
  environment.systemPackages = with pkgs; [
    gcc14
    xdg-utils
    slurp
    onnx2c
    udiskie
    simulide    
    vscodium
    jupyter
  ];

  # -----------------------------
  # System Configuration
  # -----------------------------

  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };

  time.timeZone = "America/Sao_Paulo";

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

  services.tlp = {
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

  modules = {
    hyprland = {
      terminal = "alacritty";
      fileManager = "nautilus";
      appLauncher = "wofi";
      browser = "brave";

      keyboardLayout = "br";
      keyboardVariant = "abnt2";
    };

    swaybg = {
      eDP-1 = "/home/luvier/wallpaper.jpg";
    };
  };

  home-manager.users.luvier = { pkgs, ... }: {
    home.stateVersion = "24.11";

    programs.git = {
      enable = true;
      userName = "decioluvier";
      userEmail = "decioluvieriii@gmail.com";
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;

      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        ms-toolsai.jupyter
        ms-python.python
      ];

      userSettings = {
        "editor.stickyScroll.enabled" = false;
        "editor.minimap.enabled" = false;
        "git.enabled" = true;
        "git.confirmSync" = false;
        "explorer.confirmDelete" = false;
      };
    };
  };
}
