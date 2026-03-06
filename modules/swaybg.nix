{ config, pkgs, lib, ... }:

let cfg = config.modules.swaybg;
in {

  options.modules.swaybg = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
  };

  config = {
    environment.systemPackages = [
      pkgs.swaybg
    ];

    home-manager.sharedModules = [{
      wayland.windowManager.hyprland.extraConfig =
        lib.concatStringsSep "\n"
          (lib.mapAttrsToList (m: img: "exec-once = swaybg -o ${m} -i ${img} -m fill") cfg);
    }];
  };
}