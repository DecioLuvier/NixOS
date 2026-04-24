{ pkgs }:

let
  c-env = pkgs.buildEnv {
    name = "c-env";
    paths = [
      pkgs.gcc
      pkgs.perf
      pkgs.clang
    ];
    ignoreCollisions = true;
  };

in
  "${c-env}/bin"
