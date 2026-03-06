{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.waybar
    pkgs.pavucontrol
    pkgs.playerctl
    pkgs.brightnessctl
    pkgs.networkmanagerapplet
  ];

  fonts.packages = [
    pkgs.nerd-fonts.fira-code
    pkgs.font-awesome
  ];

  home-manager.sharedModules = [
    {
      programs.waybar = {
        enable = true;

        settings.mainBar = {
          layer = "top";
          position = "top";
          margin-left = 10;
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
            on-click = "wofi --show run";
            on-click-right = "nwg-drawer";
            on-click-middle = "pkill -9 wofi";
          };

          "clock#date" = {
            format = "󰥔  {:%H:%M}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          memory = {
            interval = 30;
            format = " {used:0.2f} / {total:0.0f} GB";
            on-click = "alacritty -e btop";
          };

          battery = {
            interval = 2;
            format = "{icon} {capacity}%";
            format-icons = [ "" "" "" "" "" ];
          };

          "custom/storage" = {
            format = " {}";
            return-type = "json";
            interval = 60;

            exec = pkgs.writeShellScript "storage" ''
              df -h / | awk 'NR==2 {print "{\"text\":\"" $3 "/" $2 "\", \"tooltip\":\"" $1 ": " $3 "/" $2 "\"}"}'
            '';
          };

          "custom/power" = {
            format = " 󰐥 ";
            tooltip = false;
            on-click = "wlogout";
          };

          cpu = {
            interval = 1;
            format = " {usage}%";
          };

          "hyprland/workspaces" = {
            all-outputs = true;
            format = "{name}";
            sort-by-number = true;
          };

          wireplumber = {
            on-click = "pavucontrol";
            format = "󰕾 {volume}%";
            format-muted = "󰖁";
          };

          tray = {
            icon-size = 15;
            spacing = 5;
          };
        };

        style = ''
          * {
            font-family: "FiraCode Nerd Font", "Font Awesome 6 Free";
            font-size: 14px;
          }

          #waybar {
            background: transparent;
            color: #ffffff;
          }

          #workspaces button.active {
            background: #025939;
          }

          #custom-power {
            background-color: #f53c3c;
          }

          #custom-rofi {
            background-color: #025939;
          }
        '';
      };
    }
  ];
}