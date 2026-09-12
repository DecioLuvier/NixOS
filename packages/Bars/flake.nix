{
  description = "Bars: custom GTK4 status bars (top + bottom) for Hyprland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/a5cc6f2c37bf518436dc8d1c288ccd0c43c2f4c4";
    flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        bars = pkgs.stdenv.mkDerivation {
          pname = "bars";
          version = "0.1.0";
          src = ./.;

          nativeBuildInputs = [ pkgs.pkg-config pkgs.wrapGAppsHook4 pkgs.makeWrapper ];
          buildInputs = [ pkgs.gtk4 pkgs.gtk4-layer-shell ];

          dontConfigure = true;

          buildPhase = ''
            runHook preBuild
            g++ -std=c++20 -pthread -I. -o bars \
              $(find . -name '*.cpp') \
              $(pkg-config --cflags --libs gtk4 gtk4-layer-shell-0)
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin $out/share/bars
            cp bars $out/bin/bars
            cp ${./main.css} $out/share/bars/main.css
            runHook postInstall
          '';

          postFixup = ''
            wrapProgram $out/bin/bars \
              --set BARS_CSS_PATH "$out/share/bars/main.css"
          '';
        };
      in
      {
        packages.default = bars;
      }
    ) // {
      nixosModules.default = { pkgs, ... }:
        let
          bars = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
          environment.systemPackages = [ bars ];

          systemd.user.services.bars = {
            description = "Custom GTK status bars";
            unitConfig = {
              StartLimitIntervalSec = 30;
              StartLimitBurst = 20;
            };
            serviceConfig = {
              ExecStart = "${bars}/bin/bars";
              Restart = "always";
              RestartSec = 2;
            };
          };
        };
    };
}
