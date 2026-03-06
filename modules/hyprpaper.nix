{ config, pkgs, lib, ... }:

let cfg = config.modules.hyprpaper;
in {

  options.modules.hyprpaper = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
  };

  config = {
    environment.systemPackages = [ 
      pkgs.hyprpaper 
      ];

    home-manager.sharedModules = [{
      xdg.configFile."hypr/hyprpaper.conf".text =
        lib.concatStringsSep "\n\n"
          (lib.mapAttrsToList (m: img: ''
            monitor = ${m}
            path = ${img}
            fit_mode = cover
          '') cfg);
    }];
  };

}