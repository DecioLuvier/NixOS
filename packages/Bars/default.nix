{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "bars";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [ pkgs.pkg-config pkgs.wrapGAppsHook4 pkgs.makeWrapper ];
  buildInputs = [ pkgs.gtk4 pkgs.gtk4-layer-shell ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    g++ -std=c++20 -o bars \
      src/main.cpp src/bar_window.cpp \
      $(pkg-config --cflags --libs gtk4 gtk4-layer-shell-0)
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/bars
    cp bars $out/bin/bars
    cp ${./style.css} $out/share/bars/style.css
    runHook postInstall
  '';

  # runs after wrapGAppsHook4's own wrapping, appends our env var
  postFixup = ''
    wrapProgram $out/bin/bars \
      --set BARS_CSS_PATH "$out/share/bars/style.css"
  '';
}
