{ pkgs, ... }:

{
  kernel.python.minimal = {
    enable = true;

    extraPackages = ps: with ps; [
      notebook
      torch
      torchvision
      tqdm
      matplotlib
      torchinfo
      onnxscript
      onnxruntime
    ];
  };
}