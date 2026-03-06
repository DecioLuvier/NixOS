{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.waybar;
in
{
  options.modules.waybar = {
    enable = mkEnableOption "Waybar status bar";

    user = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "User account that should receive the Waybar Home Manager configuration.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.user != null;
        message = "modules.waybar.enable requires modules.waybar.user to be set.";
      }
    ];

    environment.systemPackages = with pkgs; [
      waybar
      pavucontrol
      playerctl
      brightnessctl
      networkmanagerapplet
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      font-awesome
    ];

    home-manager.users = mkIf (cfg.user != null) {
      "${cfg.user}" = { pkgs, ... }: {
        programs.waybar = {
          enable = true;

          settings = {
          mainBar = {
            layer = "top";
            position = "top";
            margin-left = 10;
            margin-bottom = 0;
            margin-right = 10;
            spacing = 5;
            
            modules-left = [
              "custom/rofi"
              "clock#date"
              "hyprland/workspaces"
              "custom/spotify"
            ];
            
            modules-right = [
              "custom/storage"
              "memory"
              "cpu"
              "battery"
              "wireplumber"
              "tray"
              "custom/power"
            ];
            
            "custom/rofi" = {
              format = "";
              tooltip = false;
              on-click-right = "nwg-drawer";
              on-click = "wofi --show run";
              on-click-middle = "pkill -9 wofi";
            };
            
            "custom/screenshot_t" = {
              format = " ";
              on-click = "grimblast copy output";
              on-click-right = "grimblast copy area";
            };
            
            "clock#date" = {
              format = "󰥔  {:%H:%M}";
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
              today-format = "<b>{}</b>";
            };
          
            
            memory = {
              interval = 30;
              format = " {used:0.2f} / {total:0.0f} GB";
              on-click = "alacritty -e btop";
            };
            
            battery = {
              interval = 2;
              states = {
                good = 95;
                warning = 30;
                critical = 15;
              };
              format = "{icon} {capacity}%";
              format-charging = " {capacity}%";
              format-plugged = " {capacity}%";
              format-icons = ["" "" "" "" ""];
            };
            
            "custom/storage" = {
              format = " {}";
              format-alt = "{percentage}% ";
              format-alt-click = "click-right";
              return-type = "json";
              interval = 60;
              exec = pkgs.writeShellScript "storage" ''
                df -h / | awk 'NR==2 {print "{\"text\":\"" $3 "/" $2 "\", \"alt\":\"" $5 "\", \"tooltip\":\"" $1 ": " $3 "/" $2 " (" $5 ")\"}"}' 
              '';
            };
          
            "custom/power" = {
              format = " 󰐥 ";
              tooltip = false;
              on-click = "wlogout";
            };
            
            cpu = {
              interval = 1;
              format = " {max_frequency}GHz <span color=\"darkgray\">| {usage}%</span>";
              max-length = 13;
              min-length = 13;
            };
            
            "hyprland/workspaces" = {
              all-outputs = true;
              format = "{name}";
              on-scroll-up = "hyprctl dispatch workspace e+1 1>/dev/null";
              on-scroll-down = "hyprctl dispatch workspace e-1 1>/dev/null";
              sort-by-number = true;
              active-only = false;
            };
            
            wireplumber = {
              on-click = "pavucontrol";
              on-click-right = "amixer sset Master toggle 1>/dev/null";
              format = "<span foreground='#fab387'>󰕾</span>  {volume}%";
              format-muted = " ";
              format-source = "";
              format-source-muted = "";
              format-icons = {
                headphone = " ";
                hands-free = " ";
                headset = " ";
                phone = " ";
                portable = " ";
                car = " ";
                default = [" " " " " "];
              };
            };
            
            tray = {
              icon-size = 15;
              spacing = 5;
            };
          };
        };
        
        style = ''
          * {
              font-family: "Fira Sans Semibold", "Symbols Nerd Font", "FiraCode Nerd Font", "Font Awesome 6 Free", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
              font-size: 14px;
              font-weight: 900;
              margin: 0;
              padding: 0;
              transition-property: background-color;
              transition-duration: 0.5s;
          }

          * {
              border: none;
              border-radius: 3px;
              min-height: 0;
              margin: 0.2em 0.3em 0.2em 0.3em;
          }

          #waybar {
              background-color: transparent;
              color: #ffffff;
              transition-property: background-color;
              transition-duration: 0.5s;
              border-radius: 0px;
              margin: 0px 0px;
          }

          window#waybar.hidden {
            opacity: 0.2;
          }

          #workspaces button {
              padding: 3px 5px;
              margin: 3px 5px;
              border-radius: 6px;
              color: #ffffff;
              background-color: #111827;
              transition: all 0.3s ease-in-out;
              font-size: 13px;
          }

          #workspaces button.active {
              color: #ffffff;
              background: #025939;
          }

          #workspaces button:hover {
              background: #333333;
          }

          #workspaces button.urgent {
              background-color: #eb4d4b;
          }

          #workspaces {
              background-color: #111827;
              border-radius: 14px;
              padding: 3px 6px;
          }

          #window {
              background-color: #111827;
              font-size: 15px;
              font-weight: 800;
              color: #ffffff;
              border-radius: 14px;
              padding: 3px 6px;
              margin: 2px;
              opacity: 1;
          }

          #clock,
          #battery,
          #cpu,
          #memory,
          #disk,
          #pulseaudio,
          #wireplumber,
          #custom-media,
          #mode,
          #idle_inhibitor,
          #mpd,
          #bluetooth,
          #custom-hyprPicker,
          #custom-power-menu,
          #custom-spotify,
          #custom-weather,
          #custom-pacman,
          #custom-storage,
          #custom-power,
          #custom-rofi,
          #custom-screenshot_t,
          #tray {
              background-color: #111827;
              color: #ffffff;
              border-radius: 14px;
              padding: 6px 12px;
              margin: 2px;
          }

          #battery.charging {
              background-color: #26a65b;
          }

          #battery.warning:not(.charging) {
              background-color: #ffb86c;
              color: #000000;
          }

          #battery.critical:not(.charging) {
              background-color: #f53c3c;
              color: #ffffff;
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
          }

          @keyframes blink {
              to {
                  background-color: #ffffff;
                  color: #000000;
              }
          }

          #tray > .passive {
              -gtk-icon-effect: dim;
          }

          #tray > .needs-attention {
              -gtk-icon-effect: highlight;
              background-color: #eb4d4b;
          }

          #clock#date {
              background-color: #111827;
          }

          #custom-power {
              background-color: #f53c3c;
          }

          #custom-rofi {
              background-color: #025939;
              font-size: 18px;
          }

          #custom-pacman {
              background-color: #1e5128;
          }

          #wireplumber {
              background-color: #1f3a5f;
          }

          #custom-screenshot_t {
              background-color: #4d194d;
          }
        '';
      };
    };
  };
};
}
