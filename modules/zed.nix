{ config, pkgs, lib, ... }:

{
  config = {
    home-manager.sharedModules = [
      ({ pkgs, ... }: {
        programs.zed-editor = {
          enable = true;
          extensions = [ "html" "toml" ];
          userSettings = {
            terminal = {
              shell = {
                program = "claude";
              };
              env = {
                TERM = "xterm-256color";
              };
            };
            ui_font_size = 16;
            buffer_font_size = 14;
          };
        };
      })
    ];
  };
}
