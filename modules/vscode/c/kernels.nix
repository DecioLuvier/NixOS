{ inputs, system }:

let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };

  c-env = pkgs.buildEnv {
    name = "c-env";
    paths = [
      pkgs.gcc
      pkgs.gnumake      
      pkgs.perf
      pkgs.clang
      pkgs.clang-tools
    ];
    ignoreCollisions = true;
  };
in
  "${c-env}/bin"