{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    onnx2c.url = "path:../../packages/onnx2c";
    onnx2pytorch.url = "path:../../packages/onnx2pytorch";
    emx-onnx-cgen.url = "path:../../packages/emx-onnx-cgen";  
  };

  outputs = { self, nixpkgs, flake-utils, onnx2c, onnx2pytorch, emx-onnx-cgen }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system;  config.allowUnfree = true; };

        mkCodium = { kernels, settings, extensions }:
          let
            codium-base = pkgs.vscode-with-extensions.override {
              vscode = pkgs.vscodium;
              vscodeExtensions = extensions;
            };
          in pkgs.writeShellScriptBin "codium" ''
            export HOME="$(mktemp -d)"
            export VSCODE_USER_DATA="$(mktemp -d)"

            export PATH="${pkgs.coreutils}/bin:${kernels}:$PATH"

            mkdir -p "$VSCODE_USER_DATA/User"
            cp ${settings} "$VSCODE_USER_DATA/User/settings.json"

            exec ${codium-base}/bin/codium --user-data-dir="$VSCODE_USER_DATA" "$@"
          '';

        python = mkCodium {
          kernels = import ./python/kernels.nix {
            inherit pkgs;
            onnx2c = onnx2c.packages.${system}.default;
            onnx2pytorch = onnx2pytorch.packages.${system}.default;
            emx-onnx-cgen = emx-onnx-cgen.packages.${system}.default;
          };
          settings = import ./python/settings.nix { inherit pkgs; };
          extensions = import ./python/extensions.nix { inherit pkgs; };
        };

        c = mkCodium {
          kernels = import ./c/kernels.nix { inherit pkgs; };
          settings = import ./c/settings.nix { inherit pkgs; };
          extensions = import ./c/extensions.nix { inherit pkgs; };
        };

      launcherScript = pkgs.writeShellScriptBin "launcher-script" ''
        fzf=$1
        shift

        opt1="$1"
        cmd1="$2"
        opt2="$3"
        cmd2="$4"

        choice=$(printf "%s\n%s\n" "$opt1" "$opt2" | $fzf)
        [ -z "$choice" ] && exit

        case "$choice" in
          "$opt1") cmd="$cmd1" ;;
          "$opt2") cmd="$cmd2" ;;
          *) exit ;;
        esac

        folder=$(find ~ -type d -maxdepth 3 2>/dev/null | $fzf)
        [ -z "$folder" ] && exit

        exec "$cmd" "$folder"
      '';

      launcher = pkgs.writeShellScriptBin "launcher" ''
        exec ${launcherScript}/bin/launcher-script \
          ${pkgs.fzf}/bin/fzf \
          "🐍 Python" ${python}/bin/codium \
          "💻 C"      ${c}/bin/codium
      '';
      
      in {
        packages.default = launcher;
      }
    );
}