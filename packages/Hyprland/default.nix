{ pkgs, lib, config, ... }:

let
  # ----------------------------------------------------------------------------
  # Persona 5 Royal palette (Frost-Phoenix config, Gruvbox -> P5R recolor)
  # ----------------------------------------------------------------------------
  p5 = {
    bg      = "0a0a0a"; # near black
    bgAlt   = "141414";
    bgSoft  = "1e1e1e";
    surface = "262626";
    red     = "e4002b"; # P5R signature red
    redDim  = "a3001f";
    redHot  = "ff1e3c";
    white   = "f5f5f5";
    gray    = "8a8a8a";
    grayDim = "4d4d4d";
  };
  h = c: "#${c}";
in
{
  options.programs.hyprland-desktop.wallpaper = lib.mkOption {
    type    = lib.types.path;
    default = ./assets/background.png;
  };

  config = {

    programs.hyprland = {
      enable   = true;
      withUWSM = true;
    };

    xdg.portal = {
      enable       = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
    };

    environment.systemPackages = with pkgs; [
      grimblast brightnessctl playerctl pavucontrol
      swaynotificationcenter networkmanagerapplet wob alsa-utils
      udiskie kdePackages.polkit-kde-agent-1
      thunar wofi firefox swaybg wlogout
      waybar hyprlock hypridle
      wl-clipboard wl-clip-persist cliphist hyprpicker
      papirus-icon-theme bibata-cursors
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code nerd-fonts.jetbrains-mono
      font-awesome fira-sans nerd-fonts.symbols-only roboto
    ];

    home-manager.sharedModules = [
      {
        home.pointerCursor = {
          enable  = true;
          name    = "Bibata-Modern-Classic";
          size    = 24;
          package = pkgs.bibata-cursors;
          gtk.enable = true;
        };

        # --------------------------------------------------------------------
        # Session variables (Frost variables.nix, safe subset)
        # --------------------------------------------------------------------
        home.sessionVariables = {
          NIXOS_OZONE_WL = 1;
          GDK_BACKEND = "wayland";
          MOZ_ENABLE_WAYLAND = 1;
          QT_QPA_PLATFORM = "wayland";
          QT_AUTO_SCREEN_SCALE_FACTOR = 1;
          QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
          SDL_VIDEODRIVER = "wayland";
          CLUTTER_BACKEND = "wayland";
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
          XDG_SESSION_DESKTOP = "Hyprland";
          WLR_NO_HARDWARE_CURSORS = 1;
          GTK_THEME = "Colloid-Red-Dark";
          GRIMBLAST_HIDE_CURSOR = 0;
        };

        # --------------------------------------------------------------------
        # GTK theme: Colloid dark + red accent (Frost uses Colloid green/gruvbox)
        # --------------------------------------------------------------------
        gtk = {
          enable = true;
          theme = {
            name    = "Colloid-Red-Dark";
            package = pkgs.colloid-gtk-theme.override {
              themeVariants = [ "red" ];
              colorVariants = [ "dark" ];
              tweaks        = [ "rimless" ];
            };
          };
          iconTheme = {
            name    = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
          };
        };

        # --------------------------------------------------------------------
        # Alacritty - P5R colors
        # --------------------------------------------------------------------
        programs.alacritty = {
          enable = true;
          settings = {
            window.opacity = 0.9;
            window.blur    = true;
            window.padding = { x = 10; y = 10; };
            colors = {
              primary = { background = h p5.bg; foreground = h p5.white; };
              cursor  = { text = h p5.bg; cursor = h p5.red; };
              normal  = {
                black  = h p5.bgSoft;  red = h p5.red;    green = "#3ddc84";
                yellow = "#ffc857";    blue = "#4aa3ff";   magenta = "#ff5c8a";
                cyan   = "#4fd6d2";    white = h p5.white;
              };
              bright = {
                black  = h p5.grayDim; red = h p5.redHot; green = "#5cf0a0";
                yellow = "#ffd982";    blue = "#7ac0ff";  magenta = "#ff85ab";
                cyan   = "#7ff0ec";    white = "#ffffff";
              };
            };
            font.normal.family = "JetBrainsMono Nerd Font";
            font.size = 12.0;
          };
        };

        # --------------------------------------------------------------------
        # Notifications: swaync (Frost uses swaync) - P5R restyle
        # --------------------------------------------------------------------
        services.swaync = {
          enable = true;
          settings = {
            positionX = "right";
            positionY = "top";
            layer = "overlay";
            control-center-layer = "top";
            notification-window-width = 400;
            timeout = 10;
            timeout-low = 5;
            timeout-critical = 0;
            fit-to-screen = true;
            control-center-width = 420;
            notification-icon-size = 48;
            widgets = [ "title" "dnd" "notifications" "mpris" ];
          };
          style = ''
            * { font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free"; font-size: 13px; }
            .notification-row { background: transparent; }
            .notification {
              border-radius: 0;
              margin: 6px 12px;
              border-left: 4px solid ${h p5.red};
              background: ${h p5.bgAlt};
            }
            .notification-content { padding: 10px; color: ${h p5.white}; }
            .close-button {
              background: ${h p5.red}; color: ${h p5.bg};
              border-radius: 0; margin-top: 6px; margin-right: 6px;
            }
            .close-button:hover { background: ${h p5.redHot}; }
            .notification-default-action:hover { background: ${h p5.bgSoft}; }
            .control-center {
              background: ${h p5.bg};
              border: 2px solid ${h p5.red};
              border-radius: 0;
            }
            .control-center .notification { background: ${h p5.bgAlt}; }
            .widget-title { color: ${h p5.white}; font-weight: bold; margin: 8px; }
            .widget-title > button {
              background: ${h p5.red}; color: ${h p5.bg};
              border-radius: 0; padding: 4px 10px;
            }
            .widget-dnd > switch { background: ${h p5.surface}; border-radius: 0; }
            .widget-dnd > switch:checked { background: ${h p5.red}; }
          '';
        };

        # --------------------------------------------------------------------
        # Waybar - P5R red/black slab bar
        # --------------------------------------------------------------------
        programs.waybar = {
          enable = true;
          settings.mainBar = {
            layer = "top";
            position = "top";
            height = 34;
            spacing = 4;
            modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
            modules-center = [ "clock" ];
            modules-right  = [ "tray" "pulseaudio" "backlight" "battery" "network" "custom/notif" ];

            "hyprland/workspaces" = {
              format = "{id}";
              on-click = "activate";
              all-outputs = true;
            };
            "hyprland/window" = { max-length = 60; separate-outputs = true; };
            clock = {
              format = " {:%H:%M}";
              format-alt = " {:%a %d %b %Y}";
              tooltip-format = "<tt>{calendar}</tt>";
            };
            battery = {
              format = "{icon} {capacity}%";
              format-charging = " {capacity}%";
              format-icons = [ "" "" "" "" "" ];
              states = { warning = 30; critical = 15; };
            };
            network = {
              format-wifi = " {signalStrength}%";
              format-ethernet = " ";
              format-disconnected = "睊";
              tooltip-format = "{ifname} {ipaddr}";
            };
            pulseaudio = {
              format = "{icon} {volume}%";
              format-muted = " ";
              format-icons = { default = [ "" "" "" ]; };
              on-click = "pavucontrol";
            };
            backlight = { format = " {percent}%"; };
            tray = { spacing = 10; };
            "custom/notif" = {
              format = "";
              on-click = "swaync-client -t -sw";
              tooltip = false;
            };
          };
          style = ''
            * {
              font-family: "JetBrainsMono Nerd Font";
              font-size: 13px;
              min-height: 0;
              border: none;
              border-radius: 0;
            }
            window#waybar {
              background: ${h p5.bg};
              color: ${h p5.white};
              border-bottom: 2px solid ${h p5.red};
            }
            #workspaces button {
              padding: 0 10px;
              color: ${h p5.gray};
              background: transparent;
            }
            #workspaces button.active {
              color: ${h p5.bg};
              background: ${h p5.red};
              font-weight: bold;
            }
            #workspaces button:hover { color: ${h p5.redHot}; background: ${h p5.bgSoft}; }
            #window { color: ${h p5.gray}; padding: 0 10px; }
            #clock {
              color: ${h p5.bg};
              background: ${h p5.red};
              padding: 0 16px;
              font-weight: bold;
            }
            #pulseaudio, #backlight, #battery, #network, #tray, #custom-notif {
              padding: 0 10px;
              background: ${h p5.bgAlt};
              margin: 4px 0;
            }
            #custom-notif { color: ${h p5.red}; padding-right: 14px; }
            #battery.warning { color: #ffc857; }
            #battery.critical { color: ${h p5.redHot}; }
          '';
        };

        # --------------------------------------------------------------------
        # wofi - kept (hotkey $mainMod+SPACE unchanged) - P5R restyle
        # --------------------------------------------------------------------
        programs.wofi = {
          enable = true;
          settings = {
            allow_images = true;
            hide_scroll  = true;
            no_actions   = false;
            term         = "alacritty";
            mode         = "drun";
            show         = true;
            width        = 640;
            lines        = 10;
            prompt       = "TAKE YOUR TIME";
          };
          style = ''
            * { font-family: "JetBrainsMono Nerd Font", monospace; font-size: 14px; }
            window {
              background-color: ${h p5.bg};
              border: 3px solid ${h p5.red};
              border-radius: 0;
            }
            #input {
              margin: 8px;
              border: none;
              border-bottom: 2px solid ${h p5.red};
              border-radius: 0;
              background-color: ${h p5.bgAlt};
              color: ${h p5.white};
              padding: 8px;
            }
            #inner-box { background-color: ${h p5.bg}; }
            #outer-box { margin: 4px; padding: 10px; background-color: ${h p5.bg}; }
            #scroll { margin: 4px; }
            #text { padding: 6px; color: ${h p5.white}; }
            #entry:nth-child(even) { background-color: ${h p5.bgAlt}; }
            #entry:selected { background-color: ${h p5.red}; }
            #text:selected { background: transparent; color: ${h p5.bg}; font-weight: bold; }
          '';
        };

        # --------------------------------------------------------------------
        # wlogout - P5R
        # --------------------------------------------------------------------
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
            * { background-image: none; box-shadow: none; font-family: "JetBrainsMono Nerd Font"; }
            window { background-color: rgba(10, 10, 10, 0.9); }
            button {
              border-radius: 0;
              border: 2px solid ${h p5.red};
              color: ${h p5.white};
              background-color: ${h p5.bgAlt};
              background-repeat: no-repeat;
              background-position: center;
              background-size: 25%;
              margin: 8px;
            }
            button:focus, button:active, button:hover {
              background-color: ${h p5.red};
              color: ${h p5.bg};
              outline-style: none;
            }
            #lock      { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png")); }
            #logout    { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png")); }
            #suspend   { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/suspend.png")); }
            #hibernate { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png")); }
            #shutdown  { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png")); }
            #reboot    { background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png")); }
          '';
        };

        # ====================================================================
        # hyprlock - Frost hyprlock.nix, Gruvbox -> P5R recolor,
        # background = repo wallpaper (background.png unchanged)
        # ====================================================================
        programs.hyprlock = {
          enable = true;
          settings = {
            general = {
              hide_cursor = true;
              ignore_empty_input = true;
              fractional_scaling = 0;
            };

            background = [
              {
                path = "${config.programs.hyprland-desktop.wallpaper}";
                color = "rgba(10, 10, 10, 255)";
                blur_passes = 2;
                vibrancy_darkness = 0.0;
              }
            ];

            shape = [
              {
                size = "300, 50";
                rounding = 0;
                border_size = 2;
                color = "rgba(20, 20, 20, 0.5)";
                border_color = "rgba(228, 0, 43, 0.95)";
                position = "0, 270";
                halign = "center";
                valign = "bottom";
              }
            ];

            label = [
              {
                text = ''cmd[update:1000] echo "$(date +'%k:%M')"'';
                font_size = 115;
                font_family = "JetBrainsMono Nerd Font Bold";
                shadow_passes = 3;
                color = "rgba(245, 245, 245, 0.9)";
                position = "0, -150";
                halign = "center";
                valign = "top";
              }
              {
                text = ''cmd[update:1000] echo "- $(date +'%A, %B %d') -" '';
                font_size = 18;
                font_family = "JetBrainsMono Nerd Font";
                shadow_passes = 3;
                color = "rgba(245, 245, 245, 0.9)";
                position = "0, -350";
                halign = "center";
                valign = "top";
              }
              {
                text = "  $USER";
                font_size = 15;
                font_family = "JetBrainsMono Nerd Font Bold";
                color = "rgba(245, 245, 245, 1)";
                position = "0, 284";
                halign = "center";
                valign = "bottom";
              }
            ];

            input-field = [
              {
                size = "300, 50";
                rounding = 0;
                outline_thickness = 2;
                dots_spacing = 0.4;
                font_color = "rgba(245, 245, 245, 0.9)";
                font_family = "JetBrainsMono Nerd Font Bold";
                outer_color = "rgba(228, 0, 43, 0.95)";
                inner_color = "rgba(20, 20, 20, 0.5)";
                check_color = "rgba(255, 30, 60, 0.95)";
                fail_color = "rgba(163, 0, 31, 0.95)";
                capslock_color = "rgba(255, 200, 87, 0.95)";
                bothlock_color = "rgba(255, 200, 87, 0.95)";
                hide_input = false;
                fade_on_empty = false;
                placeholder_text = ''<i><span foreground="##f5f5f5">Enter Password</span></i>'';
                position = "0, 200";
                halign = "center";
                valign = "bottom";
              }
            ];

            animation = [ "inputFieldColors, 0" ];
          };
        };

        # --------------------------------------------------------------------
        # hypridle (Frost binds lock on lid; here full idle daemon)
        # --------------------------------------------------------------------
        services.hypridle = {
          enable = true;
          settings = {
            general = {
              lock_cmd = "pidof hyprlock || hyprlock";
              before_sleep_cmd = "loginctl lock-session";
              after_sleep_cmd = "hyprctl dispatch dpms on";
            };
            listener = [
              { timeout = 300;  on-timeout = "brightnessctl -s set 10%"; on-resume = "brightnessctl -r"; }
              { timeout = 360;  on-timeout = "loginctl lock-session"; }
              { timeout = 600;  on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
              { timeout = 1800; on-timeout = "systemctl suspend"; }
            ];
          };
        };

        # ====================================================================
        # Hyprland - Frost hyprland.nix
        # ====================================================================
        systemd.user.targets.hyprland-session.Unit.Wants = [
          "xdg-desktop-autostart.target"
        ];

        wayland.windowManager.hyprland = {
          enable = true;
          package = null;        # provided by NixOS programs.hyprland
          portalPackage = null;
          configType = "hyprlang";
          xwayland.enable = true;
          systemd.enable = false; # UWSM manages the session

          settings = {
            "$mainMod" = "SUPER";

            # ----------------------------------------------------------------
            # exec-once - Frost exec-once.nix (adapted: swaybg wallpaper,
            # Bibata-Modern-Classic cursor, polkit agent; app launches dropped)
            # ----------------------------------------------------------------
            exec-once = [
              "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
              "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
              "hyprctl setcursor Bibata-Modern-Classic 24 &"
              "nm-applet --indicator &"
              "wl-clip-persist --clipboard both &"
              "wl-paste --watch cliphist store &"
              "waybar &"
              "swaync &"
              "udiskie --automount --notify --smart-tray &"
              "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1 &"
              "${pkgs.swaybg}/bin/swaybg -i ${config.programs.hyprland-desktop.wallpaper} -m fill &"
            ];

            # ----------------------------------------------------------------
            # hotkeys - UNCHANGED
            # ----------------------------------------------------------------
            bind = [
              "$mainMod, Tab,   workspace, previous"
              "$mainMod, N,     exec, code"
              "$mainMod, T,     exec, alacritty"
              "$mainMod, E,     exec, thunar"
              "$mainMod, B,     exec, firefox"
              "$mainMod, G,     exec, github-desktop"
              "$mainMod, R,     exec, alacritty --hold -e sudo nixos-rebuild switch --flake ~/NixOS#$(hostname)"
              "$mainMod, SPACE, exec, wofi --show drun"
              "$mainMod, Q,     killactive"
              "$mainMod, F,     fullscreen"
              "$mainMod, V,     pseudo"
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

            # ----------------------------------------------------------------
            # monitors - Frost monitors.nix
            # ----------------------------------------------------------------
            monitor = [ ",preferred,auto,auto" ];

            # ----------------------------------------------------------------
            # settings.nix - Frost, kb_layout kept br/abnt2
            # ----------------------------------------------------------------
            input = {
              kb_layout = "br";
              kb_variant = "abnt2";

              repeat_delay = 300;
              numlock_by_default = true;

              follow_mouse = 0;
              mouse_refocus = 0;
              float_switch_override_focus = 0;

              touchpad = {
                disable_while_typing = false;
                natural_scroll = true;
              };
            };

            general = {
              layout = "dwindle";

              gaps_in = 6;
              gaps_out = 12;
              border_size = 2;

              "col.active_border" = "rgb(${p5.red}) rgb(${p5.white}) 45deg";
              "col.inactive_border" = "0x00000000";
            };

            misc = {
              disable_hyprland_logo = true;
              disable_splash_rendering = false;

              focus_on_activate = true;
              middle_click_paste = false;

              disable_autoreload = false;
            };

            dwindle = {
              force_split = 2;
              preserve_split = true;
              use_active_for_splits = true;
            };

            master = {
              new_status = "master";
            };

            decoration = {
              rounding = 0;

              blur = {
                enabled = true;

                size = 3;
                noise = 0;
                passes = 2;
                contrast = 1.4;
                brightness = 1;

                xray = true;
              };

              shadow = {
                enabled = true;

                range = 20;
                render_power = 3;

                offset = "0 2";
                color = "rgba(00000055)";
              };
            };

            animations = {
              enabled = true;

              bezier = [
                "fluent_decel, 0, 0.2, 0.4, 1"
                "easeOutCirc, 0, 0.55, 0.45, 1"
                "easeOutCubic, 0.33, 1, 0.68, 1"
                "fade_curve, 0, 0.55, 0.45, 1"
              ];

              animation = [
                "windowsIn,   0, 4, easeOutCubic,  popin 20%"
                "windowsOut,  0, 4, fluent_decel,  popin 80%"
                "windowsMove, 1, 2, fluent_decel, slide"

                "fadeIn,      1, 3,   fade_curve"
                "fadeOut,     1, 3,   fade_curve"
                "fadeSwitch,  0, 1,   easeOutCirc"
                "fadeShadow,  1, 10,  easeOutCirc"
                "fadeDim,     1, 4,   fluent_decel"
                "workspaces,  1, 4,   easeOutCubic, fade"
              ];
            };

            xwayland = {
              force_zero_scaling = true;
            };

            # ----------------------------------------------------------------
            # binds.nix - Frost binds block only (keybinds themselves kept above)
            # ----------------------------------------------------------------
            binds = {
              scroll_event_delay = 100;
              movefocus_cycles_fullscreen = true;
            };

            # ----------------------------------------------------------------
            # windowrules.nix - Frost, verbatim
            # ----------------------------------------------------------------
            windowrule = [
              "match:class ^(imv)$, float on"
              "match:class ^(mpv)$, float on"
              "match:class ^(zenity)$, float on"
              "match:class ^(waypaper)$, float on"
              "match:class ^(.sameboy-wrapped)$, float on"
              "match:class ^(org.gnome.Calculator)$, float on"
              "match:class ^(org.gnome.FileRoller)$, float on"
              "match:class ^(org.pulseaudio.pavucontrol)$, float on"

              "match:class ^(rofi)$, pin on"
              "match:class ^(waypaper)$, pin on"

              "match:class ^(Aseprite)$, tile on"

              "match:class ^(zenity)$, size 850 500"

              "match:title ^(Volume Control)$, size 700 450"
              "match:title ^(Volume Control)$, move 40 55%"

              "match:title ^(Picture-in-Picture)$, pin on"
              "match:title ^(Picture-in-Picture)$, float on"

              "match:class ^(zen-beta)$, workspace 1"
              "match:class ^(codium)$, workspace 3"
              "match:class ^(Gimp-2.10)$, workspace 4"
              "match:class ^(Aseprite)$, workspace 4"
              "match:class ^(Audacious)$, workspace 5"
              "match:class ^(spotify)$, workspace 5"
              "match:class ^(com.obsproject.Studio)$, workspace 8"
              "match:class ^(discord)$, workspace 10"
              "match:class ^(WebCord)$, workspace 10"
              "match:class ^(vesktop)$, workspace 10"

              "match:class ^(mpv)$, idle_inhibit focus"
              "match:class ^(zen-beta)$, match:title ^(.*YouTube.*)$, idle_inhibit focus"
              "match:class ^(zen)$, idle_inhibit fullscreen"

              "match:class ^(xdg-desktop-portal-gtk)$, dim_around on"

              "match:xwayland true, rounding 0"

              "border_size 0, match:float 0, match:workspace w[tv1]"
              "rounding 0, match:float 0, match:workspace w[tv1]"
              "border_size 0, match:float 0, match:workspace f[1]"
              "rounding 0, match:float 0, match:workspace f[1]"
            ];

            layerrule = [
              "match:namespace rofi, dim_around on"
              "match:namespace swaync-control-center, dim_around on"
            ];

            workspace = [
              "w[tv1], gapsout:0, gapsin:0"
              "f[1], gapsout:0, gapsin:0"
            ];
          };
        };
      }
    ];
  };
}
