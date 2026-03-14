{ pkgs }:

pkgs.writeText "settings.json"
  (builtins.toJSON {
    "editor.stickyScroll.enabled" = false;
    "editor.minimap.enabled" = false;

    "git.enabled" = false;
    "explorer.confirmDelete" = false;

    "jupyter.kernels.excludePythonEnvironments" = [".*"];

    "jupyter.kernels.trusted" = [
      "__PWD__/.kernels/share/jupyter/kernels/pyfull/kernel.json"
      "__PWD__/.kernels/share/jupyter/kernels/pymini/kernel.json"
    ];
  })