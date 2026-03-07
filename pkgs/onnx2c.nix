{ lib
, stdenv
, fetchFromGitHub
, cmake
, protobuf
}:

stdenv.mkDerivation rec {
  pname = "onnx2c";
  version = "unstable-2026-01";

  src = fetchFromGitHub {
    owner = "kraiskil";
    repo = "onnx2c";
    rev = "e6308a7"; # commit atual do repo
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    protobuf
  ];

  buildInputs = [
    protobuf
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp onnx2c $out/bin/
  '';

  meta = with lib; {
    description = "ONNX to C compiler for tiny ML inference";
    homepage = "https://github.com/kraiskil/onnx2c";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = [];
  };
}