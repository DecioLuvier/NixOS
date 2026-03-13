{ pkgs, self }:

pkgs.writeText "settings.json"
  (builtins.toJSON {

    editor.stickyScroll.enabled = false;
    editor.minimap.enabled = false;

    git.enabled = false;
    explorer.confirmDelete = false;

    jupyter.kernels.excludePythonEnvironments = [".*"];

    jupyter.kernels.trusted = [
      "${self}/share/jupyter/kernels/pyfull"
      "${self}/share/jupyter/kernels/pymini"
    ];
  })
