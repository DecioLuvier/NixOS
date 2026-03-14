{ pkgs }:

pkgs.writeText "settings.json"
  (builtins.toJSON {
    "editor.stickyScroll.enabled" = false;
    "editor.minimap.enabled" = false;

    "git.enabled" = false;
    "explorer.confirmDelete" = false;

    "jupyter.kernels.excludePythonEnvironments" = [".*"];

    "jupyter.kernels.trusted" = [
      ".kernels/share/jupyter/kernels/pyfull"
      ".kernels/share/jupyter/kernels/pymini"
    ];
  })