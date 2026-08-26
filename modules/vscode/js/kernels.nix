{ inputs, system }:
let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  
  env = pkgs.buildEnv {
    name = "js-env";
    paths = [
      pkgs.bun
      pkgs.openssl
      pkgs.prisma-engines
      pkgs.mysql84
    ];
    ignoreCollisions = true;
  };
in
"${env}/bin"
