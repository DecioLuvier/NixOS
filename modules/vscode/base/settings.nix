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

    "telemetry.telemetryLevel" = "off";
    "editor.inlineSuggest.enabled" = false;
    "editor.quickSuggestions" = {
      "other" = "on";
      "comments" = "off";
      "strings" = "off";
    };
    "workbench.enableExperiments" = false;
    "ai.experimental.generateConfiguration" = false;

    "workbench.startupEditor" = "none";
    "workbench.welcomePage.walkthroughs.openOnInstall" = false;

    "workbench.activityBar.location" = "default";
    "chat.experimental.detectParticipant" = false;
    "workbench.settingByid.editor.action.inlineChat.start" = false;
  })