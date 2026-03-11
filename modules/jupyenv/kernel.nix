{ pkgs, ... }:

{
  kernel.python.default = {
    enable = true;
    displayName = "Python (Torch + ONNX)";

    # Todos os pacotes Python necessários nos notebooks
    extraPackages = ps: with ps; [
      ipykernel
      torch
      torchvision
      tqdm
      matplotlib
      torchinfo
      onnxscript
      onnxruntime
      ../packages/onnx2c.nix
    ];
  };
}