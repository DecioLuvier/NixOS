{ inputs, system }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  emx-onnx-cgen-pkg = inputs.emx-onnx-cgen.packages.${system}.default;
  code-carbon-pkg = inputs.code-carbon.packages.${system}.default;
  onnx2pytorch-pkg = inputs.onnx2pytorch.packages.${system}.default;

  python-env = pkgs.buildEnv {
    name = "python-env";
    paths = [
      pkgs.gcc
      pkgs.perf
      pkgs.renode
      pkgs.gnumake
      pkgs.gcc-arm-embedded
      pkgs.flamegraph
      pkgs.clang
      emx-onnx-cgen-pkg
      (pkgs.python313.withPackages (p: [
        p.ipykernel
        p.notebook
        p.tensorflow
        p.sympy
        p.torchao
        p.tqdm
        p.torchinfo
        p.torch
        p.matplotlib
        p.pandas
        p.onnxruntime
        p.numpy
        p.torchvision
        p.onnxconverter-common
        p.onnxscript
        code-carbon-pkg
        onnx2pytorch-pkg
      ]))
    ];
    ignoreCollisions = true;
  };
in
  "${python-env}/bin"
