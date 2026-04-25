{ pkgs }:

let
  c-env = pkgs.buildEnv {
    name = "c-env";
    paths = [
      pkgs.gcc
      pkgs.perf
      pkgs.clang
      pkgs.clang-tools
    ];
    ignoreCollisions = true;
  };

in
  "${c-env}/bin"
