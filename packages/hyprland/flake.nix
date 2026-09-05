{
  description = "Hyprland desktop environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosModules.default = { pkgs, lib, config, ... }: {
      options.programs.hyprland-desktop.wallpaper = lib.mkOption {
        type    = lib.types.str;
        default = "/home/luvier/wallpaper.jpg";
      };

      config = {

        programs.hyprland.enable = true;

        xdg.portal = {
          enable       = true;
          extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
        };

        environment.systemPackages = with pkgs; [
          grimblast brightnessctl playerctl pavucontrol
          mako networkmanagerapplet wob alsa-utils
          udiskie kdePackages.polkit-kde-agent-1
          thunar wofi firefox swaybg wlogout
        ];

        fonts.packages = with pkgs; [
          nerd-fonts.fira-code font-awesome fira-sans
          nerd-fonts.symbols-only roboto
        ];

        # ── Home Manager (shared) ───────────────────────────────────────────
        home-manager.sharedModules = [
          {
            # Cursor
            home.pointerCursor = {
              enable  = true;
              name    = "Bibata-Modern-Classic";
              size    = 24;
              package = pkgs.bibata-cursors;
            };

            # Alacritty
            programs.alacritty = {
              enable = true;
              settings = {
                window.opacity = 0.5;
                window.blur    = false;
                colors = {
                  primary   = { background = "#212121"; foreground = "#F8F8F2"; };
                  cursor    = { text = "#0E1415"; cursor = "#ECEFF4"; };
                  normal    = { black = "#21222C"; red = "#FF5555"; green = "#50FA7B"; yellow = "#FFCB6B"; blue = "#82AAFF"; magenta = "#C792EA"; cyan = "#8BE9FD"; white = "#F8F9F2"; };
                  bright    = { black = "#545454"; red = "#FF6E6E"; green = "#69FF94"; yellow = "#FFCB6B"; blue = "#D6ACFF"; magenta = "#FF92DF"; cyan = "#A4FFFF"; white = "#F8F8F2"; };
                };
                font.size = 12.0;
              };
            };

            # Mako
            services.mako = {
              enable = true;
              settings = {
                max-visible    = 10;
                layer          = "top";
                font           = "Sarasa UI SC 10";
                background-color = "#4c566add";
                text-color     = "#d8dee9";
                border-color   = "#434c5e";
                border-radius  = 7;
                max-icon-size  = 48;
                default-timeout = 10000;
                anchor         = "top-right";
                margin         = "20";
              };
            };

            # Wofi
            programs.wofi = {
              enable = true;
              settings = {
                allow_images = true;
                hide_scroll  = true;
                no_actions   = false;
                term         = "alacritty";
                mode         = "drun";
                show         = true;
              };
              style = ''
                * { font-family: "Hack", monospace; }
                window { background-color: #007d6f; }
                #input { margin: 5px; border-radius: 0px; border: none; background-color: #111826; color: #ffffff; }
                #inner-box { background-color: #111826; }
                #outer-box { margin: 2px; padding: 10px; background-color: #111826; }
                #scroll { margin: 5px; }
                #text { padding: 4px; color: #ffffff; }
                #entry:nth-child(even) { background-color: #182545; }
                #entry:selected { background-color: #00aa84; }
                #text:selected { background: transparent; }
              '';
            };

            # Wlogout
            programs.wlogout = {
              enable = true;
              layout = [
                { label = "hibernate"; action = "systemctl hibernate"; text = "Hibernate"; keybind = "h"; }
                { label = "logout";    action = "hyprctl dispatch exit"; text = "Logout";    keybind = "e"; }
                { label = "shutdown";  action = "systemctl poweroff";   text = "Shutdown";  keybind = "s"; }
                { label = "suspend";   action = "systemctl suspend";    text = "Suspend";   keybind = "u"; }
                { label = "reboot";    action = "systemctl reboot";     text = "Reboot";    keybind = "r"; }
              ];
              style = ''
                * { background-image: none; box-shadow: none; }
                window { background-color: rgba(17, 24, 38, 0.9); }
                button { border-radius: 0; border-color: #007d6f; text-decoration-color: #ffffff; color: #ffffff; background-color: #111826; border-style: solid; border-width: 1px; background-repeat: no-repeat; background-position: center; background-size: 25%; }
                button:focus, button:active, button:hover { background-color: #00aa84; outline-style: none; }
                #lock      { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png")); }
                #logout    { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png")); }
                #suspend   { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/suspend.png")); }
                #hibernate { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png")); }
                #shutdown  { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png")); }
                #reboot    { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png")); }
              '';
            };

            # Hyprland
            wayland.windowManager.hyprland = {
              enable     = true;
              configType = "hyprlang";
              settings = {
                "$mainMod" = "SUPER";

                exec-once = [
                  "navbar"
                  "mako"
                  "udiskie --automount --notify"
                  "nm-applet --indicator"
                  "swaybg -i ${config.programs.hyprland-desktop.wallpaper} -m fill"
                  "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
                ];

                bind = [
                  "$mainMod, Tab,   workspace, previous"
                  "$mainMod, N,     exec, alacritty -e nix run ~/NixOS/packages/vscode"
                  "$mainMod, C,     exec, $GODOT_PATH"
                  "$mainMod, T,     exec, alacritty"
                  "$mainMod, E,     exec, thunar"
                  "$mainMod, B,     exec, firefox"
                  "$mainMod, G,     exec, github-desktop"
                  "$mainMod, R,     exec, alacritty --hold -e sudo nixos-rebuild switch --flake ~/NixOS#$(hostname)"
                  "$mainMod, SPACE, exec, wofi --show drun"
                  "$mainMod, Q,     killactive"
                  "$mainMod, F,     fullscreen"
                  "$mainMod, left,  movefocus, l"
                  "$mainMod, right, movefocus, r"
                  "$mainMod, up,    movefocus, u"
                  "$mainMod, down,  movefocus, d"
                  "$mainMod, P,     exec, grimblast --notify copysave area ~/Pictures/$(TZ=utc date +'screenshot_%Y-%m-%d-%H%M%S.%3N.png')"
                  "$mainMod, 1, workspace, 1"  "$mainMod, 2, workspace, 2"
                  "$mainMod, 3, workspace, 3"  "$mainMod, 4, workspace, 4"
                  "$mainMod, 5, workspace, 5"  "$mainMod, 6, workspace, 6"
                  "$mainMod, 7, workspace, 7"  "$mainMod, 8, workspace, 8"
                  "$mainMod, 9, workspace, 9"  "$mainMod, 0, workspace, 10"
                  ", F1,  exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
                  ", F2,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
                  ", F3,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
                  ", F11, exec, brightnessctl set 3%-"
                  ", F12, exec, brightnessctl set 3%+"
                ];

                bindel = [
                  ", XF86AudioRaiseVolume,  exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
                  ", XF86AudioLowerVolume,  exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
                  ", XF86AudioMute,         exec, amixer sset Master toggle"
                  ", XF86MonBrightnessUp,   exec, brightnessctl s +5%"
                  ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
                ];

                bindm = [
                  "$mainMod, mouse:272, movewindow"
                  "$mainMod, mouse:273, resizewindow"
                ];

                monitor = [ ",preferred,auto,1" ];
                input   = { kb_layout = "br"; kb_variant = "abnt2"; follow_mouse = 1; accel_profile = "flat"; sensitivity = 0.5; };
                general = { gaps_in = 3; gaps_out = 5; border_size = 3; "col.active_border" = "rgb(41b883)"; "col.inactive_border" = "rgb(0b1924)"; layout = "dwindle"; snap.enabled = true; };
                decoration = { active_opacity = 1; rounding = 4; blur.enabled = false; shadow.enabled = false; };
                animations = {
                  enabled = true;
                  bezier    = "fastshot, 0.05, 0.9, 0.1, 1.05";
                  animation = [ "windowsIn, 1, 2, fastshot, slide" "windowsOut, 1, 3, default, popin 85%" "border, 1, 2, default" "workspacesIn, 1, 3, fastshot, fade" "workspacesOut, 1, 3, fastshot, fade" ];
                };
                dwindle = { special_scale_factor = 0.8; pseudotile = true; preserve_split = true; };
                misc    = { disable_hyprland_logo = true; "col.splash" = "rgb(41b883)"; background_color = "rgb(163249)"; enable_swallow = true; focus_on_activate = true; vrr = 0; };
                cursor  = { no_hardware_cursors = true; };
                binds   = { allow_workspace_cycles = true; workspace_center_on = true; movefocus_cycles_fullscreen = true; window_direction_monitor_fallback = true; };
                group   = {
                  "col.border_active"          = "rgb(1f854d)";
                  "col.border_inactive"         = "rgb(41b883)";
                  "col.border_locked_active"    = "rgb(279e60)";
                  "col.border_locked_inactive"  = "rgb(163249)";
                  groupbar = { font_family = "Fira Sans"; text_color = "rgb(163249)"; "col.active" = "rgb(1f854d)"; "col.inactive" = "rgb(41b883)"; };
                };
              };
            };
          }
        ];
      };
    };
  };
}
