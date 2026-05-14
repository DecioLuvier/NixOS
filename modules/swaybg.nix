{ config, pkgs, lib, ... }:

{
  config = {

    environment.systemPackages = [
      pkgs.swaybg
    ];

    home-manager.sharedModules = [
      {
        wayland.windowManager.hyprland.extraConfig = ''
          exec-once = swaybg -i /home/luvier/wallpaper.jpg -m fill
        '';
      }
    ];

  };
}