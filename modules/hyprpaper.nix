{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.hyprpaper;
in {
  
  options.modules.hyprpaper = {
    image = mkOption {
      type = types.path;
      default = "";
      description = "Path to wallpaper image";
    };
  };

  config = {
    environment.systemPackages = [
      pkgs.hyprpaper
    ];

    home-manager.sharedModules = [
      {
        xdg.configFile."hypr/hyprpaper.conf".text = ''
          preload = ${cfg.image}
          wallpaper = ,${cfg.image}
          splash = false
          ipc = on
        '';
      }
    ];
  };
}