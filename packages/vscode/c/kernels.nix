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
      pkgs.gcc13
      pkgs.gnumake      
      pkgs.perf
      pkgs.clang
      pkgs.clang-tools
      
      # Ferramentas de compilação e bibliotecas GTK
      pkgs.pkg-config
      pkgs.gtkmm4
      pkgs.gtk4        # Fornece o binário gtk4-broadwayd
      pkgs.entr        # Para recompilação automática ao salvar
    ];
    ignoreCollisions = true;
  };
in
  "${c-env}/bin"