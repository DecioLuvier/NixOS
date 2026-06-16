{ inputs, system }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
pkgs.writeText "settings.json"
  (builtins.toJSON {
    "editor.stickyScroll.enabled" = false;
    "editor.minimap.enabled" = false;

    "git.enabled" = false;
    "explorer.confirmDelete" = false;

    "security.workspace.trust.enabled" = false;
    "security.workspace.trust.startupPrompt" = "never";

    "C_Cpp.intelliSenseEngine" = "disabled";
    "clangd.path" = "clangd";
    "C_Cpp.default.includePath" = [
      "/run/current-system/sw/include"
      "/nix/store/**"
    ];
  })
