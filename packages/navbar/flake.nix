{
  description = "GTK4 layer-shell navbar for Hyprland (C++)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs   = nixpkgs.legacyPackages.${system};

    navbarPkg = pkgs.stdenv.mkDerivation {
      pname   = "navbar";
      version = "0.2.0";
      src     = self;

      nativeBuildInputs = [ pkgs.pkg-config pkgs.wrapGAppsHook4 ];
      buildInputs = [
        pkgs.gtk4
        pkgs.gtk4-layer-shell
        pkgs.glib
      ];

      buildPhase = ''
        runHook preBuild
        $CXX -std=c++17 -O2 -Wall bar.cpp -o navbar \
          $(pkg-config --cflags --libs gtk4 gtk4-layer-shell-0) \
          -lpthread
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        install -Dm755 navbar $out/bin/navbar
        runHook postInstall
      '';
    };

  in {
    packages.${system}.default = navbarPkg;

    apps.${system}.default = {
      type    = "app";
      program = "${navbarPkg}/bin/navbar";
    };

    nixosModules.default = { pkgs, ... }: {
      environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    };
  };
}
