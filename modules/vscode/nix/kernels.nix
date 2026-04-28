{ pkgs }:

let
  nix-env = pkgs.buildEnv {
    name = "nix-env";
    paths = [

    ];
    ignoreCollisions = true;
  };

in
  "${nix-env}/bin"
