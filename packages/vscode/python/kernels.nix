{ inputs, system }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  # onnx-simplifier 0.4.x has no py313 build (C++ ext, needs cmake, no cp313
  # wheel). Upstream renamed the project to `onnxsim`, which ships a
  # cp312-abi3 wheel that runs on py313. Consume that wheel directly.
  onnx-simplifier-pkg = pkgs.python313Packages.buildPythonPackage rec {
    pname = "onnxsim";
    version = "0.7.3";
    format = "wheel";

    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/12/ce/3bd161619ba6829d8059af3a99e2ca5f2feb2684415b91be72d825e86969/onnxsim-${version}-cp312-abi3-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl";
      hash = "sha256-iPQLDT9DTBm/BinBfrWqPI94gIWyAcaujNqdQbg+1+M=";
    };

    propagatedBuildInputs = with pkgs.python313Packages; [ onnx onnxruntime rich ];

    pythonImportsCheck = [ "onnxsim" ];
    doCheck = false;
  };

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
      (pkgs.python313.withPackages (p: [
        p.ipykernel
        p.seaborn
        p.datasets
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
        p.safetensors
        onnx-simplifier-pkg
      ]))
    ];
    ignoreCollisions = true;
  };
in
  "${python-env}/bin"
