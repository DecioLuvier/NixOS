{ pkgs, lib, config, ... }:

{
  options.programs.hyprland-desktop.wallpaper = lib.mkOption {
    type    = lib.types.path;
    default = ./assets/background.png;
  };

  config = {

    programs.hyprland.enable = true;

    xdg.portal = {
      enable       = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
    };

    environment.systemPackages = with pkgs; [
      grimblast brightnessctl playerctl pavucontrol
      networkmanagerapplet alsa-utils
      udiskie kdePackages.polkit-kde-agent-1
      thunar wofi alacritty swaybg
      wl-clipboard wl-clip-persist cliphist
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

        home.sessionVariables = {
          NIXOS_OZONE_WL = 1;
          GDK_BACKEND = "wayland";
          MOZ_ENABLE_WAYLAND = 1;
          QT_QPA_PLATFORM = "wayland";
          QT_AUTO_SCREEN_SCALE_FACTOR = 1;
          QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
          SDL_VIDEODRIVER = "wayland";
          CLUTTER_BACKEND = "wayland";
          WLR_NO_HARDWARE_CURSORS = 1;
        };

        wayland.windowManager.hyprland = {
          enable = true;
          package = null;        # provided by NixOS programs.hyprland
          portalPackage = null;
          configType = "hyprlang";
          xwayland.enable = true;
          systemd.enable = false;

          settings = {
            "$mainMod" = "SUPER";

            exec-once = [
              "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh &"
              "nm-applet --indicator &"
              "wl-clip-persist --clipboard both &"
              "wl-paste --watch cliphist store &"
              "udiskie --automount --notify --smart-tray &"
              "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1 &"
              "${pkgs.swaybg}/bin/swaybg -i ${config.programs.hyprland-desktop.wallpaper} -m fill &"
              "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE && systemctl --user start bars.service"
            ];

            bind = [
              "$mainMod, Tab,   workspace, previous"
              "$mainMod, T,     exec, alacritty"
              "$mainMod, E,     exec, thunar"
              "$mainMod, B,     exec, brave"
              "$mainMod, N,     exec, code"
              "$mainMod, SPACE, exec, wofi --show drun"
              "$mainMod, Q,     killactive"
              "$mainMod, R,     exec, alacritty --hold -e sudo nixos-rebuild switch --flake ~/NixOS#$(hostname)"
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

            monitor = [ ",preferred,auto,auto" ];

            input = {
              kb_layout = "br";
              kb_variant = "abnt2";

              sensitivity = 0.5;

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

            xwayland = {
              force_zero_scaling = true;
            };
          };
        };
      }
    ];
  };
}
