{ inputs, system }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  env = pkgs.buildEnv {
    name = "js-env";
    paths = [
      pkgs.nodejs_22
      pkgs.prisma
      pkgs.prisma-engines
      pkgs.mysql84
    ];
    ignoreCollisions = true;
  };
in
"${env}/bin"
