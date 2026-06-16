{ inputs, system }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  env = pkgs.buildEnv {
    name = "env";
    paths = [

    ];
    ignoreCollisions = true;
  };
in
"${env}/bin"
