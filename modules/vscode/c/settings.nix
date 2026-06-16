{ inputs, system }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
pkgs.writeText "settings.json"
  (builtins.toJSON {
    "window.menuBarVisibility" = "visible";
    "window.titleBarStyle" = "custom";
    "editor.stickyScroll.enabled" = false;
    "editor.minimap.enabled" = false;
    "git.enabled" = false;
    "explorer.confirmDelete" = false;
    "security.workspace.trust.enabled" = false;
    "security.workspace.trust.startupPrompt" = "never";
    "chat.disableAIFeatures" = true;
    "workbench.secondarySideBar.defaultVisibility" = "hidden";
    "workbench.colorTheme" = "Dracula Theme";
  })
