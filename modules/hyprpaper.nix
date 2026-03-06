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
        lib.concatStringsSep "\n" (
          [
            "splash = false"
            "ipc = on"
          ] ++ lib.flatten (lib.mapAttrsToList (m: img: [
            "preload = ${img}"
            "wallpaper = ${m},${img}"
          ]) cfg)
        );
    }];
  };

}