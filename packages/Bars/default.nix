{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "bars";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [ pkgs.cmake pkgs.pkg-config pkgs.wrapGAppsHook4 pkgs.makeWrapper ];
  buildInputs = [ pkgs.gtk4 pkgs.gtk4-layer-shell ];

  postInstall = ''
    mkdir -p $out/share/bars
    cp ${./style.css} $out/share/bars/style.css
  '';

  # runs after wrapGAppsHook4's own wrapping, appends our env var
  postFixup = ''
    wrapProgram $out/bin/bars \
      --set BARS_CSS_PATH "$out/share/bars/style.css"
  '';
}
