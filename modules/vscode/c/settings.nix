{ pkgs }:

pkgs.writeText "settings.json"
  (builtins.toJSON {
    "editor.stickyScroll.enabled" = false;
    "editor.minimap.enabled" = false;

    "git.enabled" = false;
    "explorer.confirmDelete" = false;

    "security.workspace.trust.enabled" = false;
    "security.workspace.trust.startupPrompt" = "never";

    # C/C++ / clangd setup limpo
    "C_Cpp.intelliSenseEngine" = "disabled";
    "clangd.path" = "clangd";
    "C_Cpp.default.includePath" = [
      "/run/current-system/sw/include"
      "/nix/store/**"
    ];
  })