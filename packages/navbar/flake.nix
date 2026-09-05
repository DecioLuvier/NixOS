{
  description = "GTK4 layer-shell navbar for Hyprland";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs   = nixpkgs.legacyPackages.${system};

    pythonEnv = pkgs.python3.withPackages (ps: with ps; [
      pygobject3
      psutil
    ]);

    navbarPkg = pkgs.stdenv.mkDerivation {
      name    = "navbar";
      src     = self;
      buildInputs = [ pkgs.gtk4 pkgs.gtk4-layer-shell pkgs.gobject-introspection pythonEnv ];
      installPhase = ''
        mkdir -p $out/share/navbar
        cp -r . $out/share/navbar/
        mkdir -p $out/bin
        cat > $out/bin/navbar <<EOF
        #!${pkgs.bash}/bin/bash
        export GI_TYPELIB_PATH="${pkgs.gtk4}/lib/girepository-1.0:${pkgs.gtk4-layer-shell}/lib/girepository-1.0:\''${GI_TYPELIB_PATH:-}"
        export LD_LIBRARY_PATH="${pkgs.gtk4}/lib:${pkgs.gtk4-layer-shell}/lib:\''${LD_LIBRARY_PATH:-}"
        exec ${pythonEnv}/bin/python3 $out/share/navbar/bar.py "\$@"
        EOF
        chmod +x $out/bin/navbar
      '';
    };

  in {
    packages.${system}.default = navbarPkg;

    apps.${system}.default = {
      type    = "app";
      program = "${navbarPkg}/bin/navbar";
    };

    nixosModules.default = { pkgs, lib, config, ... }: let
      navbarEnv = pkgs.python3.withPackages (ps: with ps; [ pygobject3 psutil ]);
      navbarBin = pkgs.writeShellScriptBin "navbar" ''
        export GI_TYPELIB_PATH="${pkgs.gtk4}/lib/girepository-1.0:${pkgs.gtk4-layer-shell}/lib/girepository-1.0:''${GI_TYPELIB_PATH:-}"
        export LD_LIBRARY_PATH="${pkgs.gtk4}/lib:${pkgs.gtk4-layer-shell}/lib:''${LD_LIBRARY_PATH:-}"
        exec ${navbarEnv}/bin/python3 ${self}/bar.py "$@"
      '';
    in {
      environment.systemPackages = [
        pkgs.gtk4
        pkgs.gtk4-layer-shell
        pkgs.gobject-introspection
        navbarBin
      ];
    };
  };
}
