{
  description = "Jupyter server — Pesquisa IFRS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    emx-onnx-cgen-src = {
      url = "github:emmtrix/emx-onnx-cgen/v1.4.0";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, emx-onnx-cgen-src }:
    flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        py  = pkgs.python3Packages;

        onnxsim = py.buildPythonPackage {
          pname = "onnxsim"; version = "0.7.3"; format = "wheel";
          src = pkgs.fetchurl {
            url = "https://files.pythonhosted.org/packages/12/ce/3bd161619ba6829d8059af3a99e2ca5f2feb2684415b91be72d825e86969/onnxsim-0.7.3-cp312-abi3-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl";
            sha256 = "sha256-iPQLDT9DTBm/BinBfrWqPI94gIWyAcaujNqdQbg+1+M=";
          };
          propagatedBuildInputs = with py; [ onnx rich ];
          doCheck = false;
        };

        emx-regex-cgen = py.buildPythonPackage {
          pname = "emx_regex_cgen"; version = "0.2.0"; format = "wheel";
          src = pkgs.fetchurl {
            url = "https://files.pythonhosted.org/packages/1c/ef/6a434f5b288d4d495179755b8eb10a6c83b9e22736f61a38fc25e6fb4c29/emx_regex_cgen-0.2.0-py3-none-any.whl";
            sha256 = "sha256-RmQLtVuZ/Qo3p1vw9WsG3gXlwoAj84Bcm4OQg2RCO8w=";
          };
          propagatedBuildInputs = with py; [ jinja2 ];
          doCheck = false;
        };

        emx-onnx-cgen = py.buildPythonPackage {
          pname = "emx-onnx-cgen"; version = "1.4.0"; format = "pyproject";
          src = emx-onnx-cgen-src;
          nativeBuildInputs = with py; [ setuptools setuptools-scm wheel pip ];
          propagatedBuildInputs = with py; [ jinja2 numpy onnx onnxruntime protobuf sympy ] ++ [ emx-regex-cgen ];
          preBuild = "export PYTHONPATH=${emx-regex-cgen}/${py.python.sitePackages}:$PYTHONPATH";
          doCheck = false;
        };

        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          jupyter ipykernel ipywidgets ipycanvas
          jupyter-collaboration
          numpy pandas matplotlib seaborn
          torch torchvision
          datasets tqdm
          onnx onnxruntime onnxconverter-common
          tabulate torchinfo codecarbon requests
        ] ++ [ onnxsim emx-regex-cgen emx-onnx-cgen ]);

        systemTools = with pkgs; [ perf gcc util-linux ];
      in
      {
        packages.default = pythonEnv;

        apps.default = {
          type = "app";
          program = "${pkgs.writeShellScript "jupyter-ifrs" ''
            export PATH=${pkgs.lib.makeBinPath systemTools}:$PATH
            exec ${pythonEnv}/bin/jupyter notebook \
              --no-browser \
              --ip=0.0.0.0 \
              --port=8888 \
              --notebook-dir="$HOME/GitHub/Pesquisa-IFRS" \
              --NotebookApp.token="" \
              --NotebookApp.password=""
          ''}";
        };
      }) //
    {
      nixosModules.default = { pkgs, lib, ... }:
        let
          env = self.packages.${pkgs.stdenv.hostPlatform.system};
        in {
          systemd.user.services.jupyter-ifrs = {
            description = "Jupyter — Pesquisa IFRS";
            wantedBy = [ "default.target" ];
            after    = [ "network.target" ];
            serviceConfig = {
              ExecStart = "${env.default}/bin/jupyter notebook"
                + " --no-browser --ip=0.0.0.0 --port=8888"
                + " --notebook-dir=%h/GitHub/Pesquisa-IFRS"
                + " --NotebookApp.token= --NotebookApp.password=";
              Restart    = "on-failure";
              RestartSec = 5;
            };
            environment.PATH = pkgs.lib.mkForce "${pkgs.lib.makeBinPath (with pkgs; [ perf gcc util-linux ])}:$PATH";
          };

          environment.systemPackages = [ env.default ] ++ (with pkgs; [ perf gcc util-linux ]);
          networking.firewall.allowedTCPPorts = [ 8888 ];
        };
    };
}
