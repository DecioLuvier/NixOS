{ inputs, system }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
pkgs.writeText "settings.json"
  (builtins.toJSON {
    "editor.stickyScroll.enabled" = false;
    "editor.minimap.enabled" = false;
    "editor.semanticHighlighting.enabled" = true;
    "editor.inlayHints.enabled" = "on";

    "git.enabled" = false;

    "explorer.confirmDelete" = false;

    "security.workspace.trust.enabled" = false;
    "security.workspace.trust.startupPrompt" = "never";

    "python.languageServer" = "Pylance";

    "python.analysis.typeCheckingMode" = "strict";

    "python.analysis.autoImportCompletions" = true;
    "python.analysis.completeFunctionParens" = true;

    "python.analysis.inlayHints.variableTypes" = true;
    "python.analysis.inlayHints.functionReturnTypes" = true;
    "python.analysis.inlayHints.parameterTypes" = true;
    "python.analysis.inlayHints.parameterNames" = "all";

    "python.analysis.semanticTokens" = true;

    "python.analysis.autoFormatStrings" = true;

    "python.analysis.diagnosticMode" = "workspace";

    "files.associations" = {
      "*.py" = "python";
    };
  })
