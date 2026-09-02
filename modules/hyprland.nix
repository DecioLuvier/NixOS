{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    
    programs.hyprland.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };

    environment.systemPackages =
      with pkgs;
      [
        grimblast
        brightnessctl
        playerctl
        pavucontrol
        waybar
        mako
        networkmanagerapplet
        wob
        alsa-utils
        udiskie
        kdePackages.polkit-kde-agent-1
        thunar
        wofi
        firefox
      ];

    home-manager.sharedModules = [{
        home.pointerCursor = {
          name = "Bibata-Modern-Classic";
          size = 24;
          package = pkgs.bibata-cursors;
        };

        wayland.windowManager.hyprland = {
          enable = true;

          settings = {
            "$mainMod" = "SUPER";

            exec-once = [
              "waybar"
              "mako"
              "udiskie --automount --notify"
              "nm-applet --indicator"
              "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
            ];

            bind = [
              "$mainMod, Tab, workspace, previous"
              "$mainMod, N, exec, alacritty -e nix run ~/NixOS/modules/vscode"
              "$mainMod, C, exec, $GODOT_PATH"
              "$mainMod, T, exec, alacritty"
              ", F1, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
              ", F2, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
              ", F3, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
              ", F11, exec, brightnessctl set 3%-"
              ", F12, exec, brightnessctl set 3%+"
              "$mainMod, E, exec, thunar"
              "$mainMod, B, exec, firefox"
              "$mainMod, G, exec, github-desktop"

              "$mainMod, R, exec, alacritty --hold -e sudo nixos-rebuild switch --flake ~/NixOS#$(hostname)"

              "$mainMod, SPACE, exec, wofi --show drun" 
              "$mainMod, Q, killactive"
              "$mainMod, F, fullscreen"
              "$mainMod, left, movefocus, l"
              "$mainMod, right, movefocus, r"
              "$mainMod, up, movefocus, u"
              "$mainMod, down, movefocus, d"
              "$mainMod, 1, workspace, 1"
              "$mainMod, 3, workspace, 3"
              "$mainMod, 2, workspace, 2"
              "$mainMod, 4, workspace, 4"
              "$mainMod, 5, workspace, 5"
              "$mainMod, 6, workspace, 6"
              "$mainMod, 7, workspace, 7"
              "$mainMod, 8, workspace, 8"
              "$mainMod, 9, workspace, 9"
              "$mainMod, 0, workspace, 10"
              "$mainMod, P, exec, grimblast --notify copysave area ~/Pictures/$(TZ=utc date +'screenshot_%Y-%m-%d-%H%M%S.%3N.png')"            ];

            monitor = [ ",preferred,auto,1" ];

            input = {
              kb_layout = "br";
              kb_variant = "abnt2";
              follow_mouse = 1;
            };

            general = {
              gaps_in = 3;
              gaps_out = 5;
              border_size = 3;
              "col.active_border" = "rgb(41b883)";  
              "col.inactive_border" = "rgb(0b1924)";  
              layout = "dwindle";

              snap = {
                enabled = true;
              };
            };

            decoration = {
              active_opacity = 1;
              rounding = 4;

              blur = {
                size = 3;
                passes = 2;
                xray = true;
              };

              shadow = {
                enabled = false;
              };
            };

            animations = {
              enabled = true;
              bezier = "fastshot, 0.05, 0.9, 0.1, 1.05";
              
              animation = [
                "windowsIn, 1, 2, fastshot, slide"
                "windowsOut, 1, 3, default, popin 85%"
                "border, 1, 2, default"
                "workspacesIn, 1, 3, fastshot, fade"
                "workspacesOut, 1, 3, fastshot, fade"
              ];
            };

            dwindle = {
              special_scale_factor = 0.8;
              pseudotile = true;
              preserve_split = true;
            };

            master = {
              new_status = "master";
              special_scale_factor = 0.8;
            };

            group = {
              "col.border_active" = "rgb(1f854d)";
              "col.border_inactive" = "rgb(41b883)";
              "col.border_locked_active" = "rgb(279e60)";
              "col.border_locked_inactive" = "rgb(163249)";

              groupbar = {
                font_family = "Fira Sans";
                text_color = "rgb(163249)";
                "col.active" = "rgb(1f854d)";
                "col.inactive" = "rgb(41b883)";
                "col.locked_active" = "rgb(279e60)";
                "col.locked_inactive" = "rgb(163249)";
              };
            };

            misc = {
              font_family = "Fira Sans";
              splash_font_family = "Fira Sans";
              disable_hyprland_logo = true;
              "col.splash" = "rgb(41b883)";
              background_color = "rgb(163249)";
              enable_swallow = true;
              focus_on_activate = true;
              vrr = 2;
            };

            render = {
              direct_scanout = false;
            };

            binds = {
              allow_workspace_cycles = true;
              workspace_back_and_forth = false;
              workspace_center_on = true;
              movefocus_cycles_fullscreen = true;
              window_direction_monitor_fallback = true;
            };

            bindel = [
              ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | awk '{if($1>100) system(\"pactl set-sink-volume @DEFAULT_SINK@ 100%\")}' && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob"
              ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob"
              ", XF86AudioMute, exec, amixer sset Master toggle | sed -En '/\\[on\\]/ s/.*\\[([0-9]+)%\\].*/\\1/ p; /\\[off\\]/ s/.*/0/p' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob"

              ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
              ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
            ];

            bindm = [
              "$mainMod, mouse:272, movewindow"
              "$mainMod, mouse:273, resizewindow"
            ];

          };
        };
      }
    ];
  };
}
