{
  description = "onnx2c - ONNX to C compiler";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.onnx2c = pkgs.stdenv.mkDerivation rec {
          pname = "onnx2c";
          version = "0.0.1";

          src = pkgs.fetchFromGitHub {
            owner = "kraiskil";
            repo = "onnx2c";
            rev = "a129890840d462e8d6dd2b0124e349eb9ace1913";
            sha256 = "sha256-ALajneiJnmTsaNTEsVX5WtWZLvu5KuA0pBZqDY7PBG0=";
            fetchSubmodules = true;
          };

          nativeBuildInputs = with pkgs; [ cmake pkg-config git ];
          buildInputs = with pkgs; [ protobuf ];

          cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];
          enableParallelBuilding = true;

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            cp ./onnx2c $out/bin/
            runHook postInstall
          '';

          checkPhase = ''
            make test
          '';

          meta = with pkgs.lib; {
            description = "Open Neural Network Exchange to C compiler";
            longDescription = ''
              Onnx2c is a ONNX to C compiler. It will read an ONNX file,
              and generate C code to be included in your project.
              Onnx2c's target is TinyML (microcontrollers).
            '';
            homepage = "https://github.com/kraiskil/onnx2c";
            license = {
              shortName = "ONNX2C-LICENSE";
              fullName = "ONNX2C custom redistribution license";
              url = "https://github.com/kraiskil/onnx2c/blob/master/LICENSE.txt";
              free = true;
              redistributable = true;
            };
            mainProgram = "onnx2c";
          };
        };

        packages.default = self.packages.${system}.onnx2c;
      }
    );
}