{
  description = "Ambiente Jupyter declarativo com Torch, ONNX e kernel efêmero usando flake-utils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    jupyenv.url = "github:tweag/jupyenv";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, jupyenv, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = jupyenv.lib.mkJupyterShell {
          inherit pkgs;

          # Nenhum pacote Python na shell, tudo vai para o kernel
          extraPackages = ps: [];

          # Ferramentas de sistema disponíveis na shell
          extraSystemPackages = with pkgs; [
            gcc
            gnumake
            cmake
            valgrind
            jupyterlab
          ];

          # Shell hook opcional
          shellHook = ''
            codium ~/IA
          '';
        };
      });
}