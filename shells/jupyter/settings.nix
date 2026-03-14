{ pkgs, pythonFull, pythonMini }:

pkgs.writeText "settings.json"
  (builtins.toJSON {
    "editor.stickyScroll.enabled" = false;
    "editor.minimap.enabled" = false;

    "git.enabled" = false;
    "explorer.confirmDelete" = false;

    "jupyter.kernels.excludePythonEnvironments" = [".*"];

    "jupyter.kernels.trusted" = [
      "${pythonFull}/share/jupyter/kernels/pyfull"
      "${pythonMini}/share/jupyter/kernels/pymini"
    ];
  })