{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.hyprland;

in {

  options.modules.hyprland = {
    terminal = mkOption {
      type = types.enum [ "alacritty" "kitty" ];
      default = "alacritty";
    };

    fileManager = mkOption {
      type = types.enum [ "nautilus" "thunar" ];
      default = "nautilus";
    };

    appLauncher = mkOption {
      type = types.enum [ "wofi" ];
      default = "wofi";
    };

    browser = mkOption {
      type = types.enum [ "firefox" "brave" ];
      default = "firefox";
    };

    keyboardLayout = mkOption {
      type = types.str;
      default = "us";
    };

    keyboardVariant = mkOption {
      type = types.str;
      default = "";
    };

  };

  config = {
    
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };

    environment.systemPackages =
      with pkgs;
      [
        bibata-cursors
        grimblast
        brightnessctl
        playerctl
        pavucontrol
        pulseaudio
        waybar
        mako
        networkmanagerapplet
        wob
        alsa-utils
        kdePackages.polkit-kde-agent-1
      ]
      ++ optional (cfg.terminal == "alacritty") pkgs.alacritty
      ++ optional (cfg.terminal == "kitty") pkgs.kitty
      ++ optional (cfg.fileManager == "nautilus") pkgs.nautilus
      ++ optional (cfg.fileManager == "thunar") pkgs.thunar
      ++ optional (cfg.appLauncher == "wofi") pkgs.wofi
      ++ optional (cfg.browser == "firefox") pkgs.firefox
      ++ optional (cfg.browser == "brave") pkgs.brave;

    programs.hyprland.enable = true;

    home-manager.sharedModules = [
      {
        wayland.windowManager.hyprland = {
          enable = true;

          settings = {
            "$mainMod" = "SUPER";
            "$terminal" = cfg.terminal;
            "$filemanager" = cfg.fileManager;
            "$launcher" = cfg.appLauncher;
            "$browser" = cfg.browser;

            exec-once = [
              "waybar"
              "mako"
              "diskie --automount --notify"
              "nm-applet --indicator"
              "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
            ];

            # Key bindings
            bind = [
              # Core functionality
              "$mainMod, C, exec, codium"
              "$mainMod, T, exec, $terminal"
              "$mainMod, E, exec, $filemanager"
              "$mainMod, G, exec, github-desktop"
              "$mainMod, B, exec, $browser"
              "$mainMod, S, exec, simulide"
              "$mainMod, Q, killactive"
              
              "$mainMod, V, togglefloating" 
              "$mainMod, SPACE, exec, $launcher --show drun"
              "$mainMod, F, fullscreen"
              "$mainMod, Y, pin"
              "$mainMod, J, togglesplit"


              # Screenshots
              ", Print, exec, $shot-region"
              "CTRL, Print, exec, $shot-window"
              "ALT, Print, exec, $shot-screen"

              # Playback control
              ", XF86AudioPlay, exec, playerctl play-pause"
              ", XF86AudioNext, exec, playerctl next"
              ", XF86AudioPrev, exec, playerctl previous"

              # Window focus
              "$mainMod, left, movefocus, l"
              "$mainMod, right, movefocus, r"
              "$mainMod, up, movefocus, u"
              "$mainMod, down, movefocus, d"

              # Window movement
              "$mainMod SHIFT, left, movewindow, l"
              "$mainMod SHIFT, right, movewindow, r"
              "$mainMod SHIFT, up, movewindow, u"
              "$mainMod SHIFT, down, movewindow, d"

              # Workspace switching (1-10)
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
            ];

            monitor = [ ",preferred,auto,1" ];

            input = {
              kb_layout = cfg.keyboardLayout;
              kb_variant = cfg.keyboardVariant;
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
                size = 15;
                passes = 2;
                xray = true;
              };

              shadow = {
                enabled = false;
              };
            };

            animations = {
              enabled = true;
              bezier = "overshot, 0.13, 0.99, 0.29, 1.1";
              animation = [
                "windowsIn, 1, 4, overshot, slide"
                "windowsOut, 1, 5, default, popin 80%"
                "border, 1, 5, default"
                "workspacesIn, 1, 6, overshot, slide"
                "workspacesOut, 1, 6, overshot, slidefade 80%"
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
              swallow_regex = "^(nautilus|nemo|thunar|btrfs-assistant.)$";
              focus_on_activate = true;
              vrr = 2;
            };

            render = {
              direct_scanout = true;
            };

            binds = {
              allow_workspace_cycles = true;
              workspace_back_and_forth = false;
              workspace_center_on = true;
              movefocus_cycles_fullscreen = true;
              window_direction_monitor_fallback = true;
            };

            # Repeatable bindings
            bindel = [
              # Volume control
              ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | awk '{if($1>100) system(\"pactl set-sink-volume @DEFAULT_SINK@ 100%\")}' && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob"
              ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob"
              ", XF86AudioMute, exec, amixer sset Master toggle | sed -En '/\\[on\\]/ s/.*\\[([0-9]+)%\\].*/\\1/ p; /\\[off\\]/ s/.*/0/p' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob"

              # Brightness control
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
