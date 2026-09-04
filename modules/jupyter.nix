{ config, pkgs, lib, ... }:

let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    jupyter
    ipykernel
    numpy
    pandas
    matplotlib

    # PyTorch (CPU build — troca por torchWithCuda se tiveres GPU configurada no NixOS)
    torch
    torchvision

    # Hugging Face / datasets
    datasets
    tqdm

    # ONNX
    onnx
    onnxruntime
    onnxsim

    # Emissões de carbono
    codecarbon
  ]);

in
{
  config = {
    # Serviço systemd que sobe o servidor Jupyter ao fazer login
    systemd.user.services.jupyter = {
      description = "Jupyter Notebook Server";
      wantedBy = [ "default.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pythonEnv}/bin/jupyter notebook"
          + " --no-browser"
          + " --ip=0.0.0.0"
          + " --port=8888"
          + " --notebook-dir=%h/GitHub/Pesquisa-IFRS";
        Restart = "on-failure";
        RestartSec = 5;
      };

      environment = {
        PYTHONPATH = "${pythonEnv}/${pythonEnv.sitePackages}";
      };
    };

    environment.systemPackages = [ pythonEnv ];

    networking.firewall.allowedTCPPorts = [ 8888 ];
  };
}
