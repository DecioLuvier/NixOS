{ pkgs }:

pkgs.mkShell {
  buildInputs = [
    (pkgs.jupyterWith.jupyterlabWith {
      kernels = [
        (pkgs.jupyterWith.iPythonWith {
          name = "python-torch";
          packages = p: with p; [
            torch
            torchvision
            matplotlib
            tqdm
            torchinfo
            onnxscript
          ];
        })
      ];
    })
  ];
}