{ inputs, system }:
let
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  # O Prisma nao publica engines para linux-nixos; apontamos para o nixpkgs.
  # buildEnv so mexe no PATH, entao as variaveis vao embrulhadas no proprio bun:
  # todo processo filho (bunx prisma, bun run) herda o ambiente.
  bun' = pkgs.symlinkJoin {
    name = "bun-prisma";
    paths = [ pkgs.bun ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for exe in bun bunx; do
        if [ -e "$out/bin/$exe" ]; then
          wrapProgram "$out/bin/$exe" \
            --set PRISMA_SCHEMA_ENGINE_BINARY "${pkgs.prisma-engines}/bin/schema-engine" \
            --set PRISMA_QUERY_ENGINE_BINARY "${pkgs.prisma-engines}/bin/query-engine" \
            --set PRISMA_QUERY_ENGINE_LIBRARY "${pkgs.prisma-engines}/lib/libquery_engine.node" \
            --set PRISMA_FMT_BINARY "${pkgs.prisma-engines}/bin/prisma-fmt"
        fi
      done
    '';
  };

  env = pkgs.buildEnv {
    name = "js-env";
    paths = [
      bun'
      pkgs.openssl
      pkgs.prisma-engines
      pkgs.mysql84
    ];
    ignoreCollisions = true;
  };
in
"${env}/bin"
