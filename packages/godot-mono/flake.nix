{
  description = "Godot 4 C#/Mono with VSCode configured as external editor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        dotnet = pkgs.dotnetCorePackages.sdk_8_0;

        # VSCode with C# tooling for editing Godot scripts.
        vscode = pkgs.vscode-with-extensions.override {
          vscodeExtensions = with pkgs.vscode-extensions; [
            ms-dotnettools.csharp
            ms-dotnettools.csdevkit
            ms-dotnettools.vscode-dotnet-runtime
          ];
        };

        # Godot's C# editor settings expect an "external editor" number:
        #   0 = None, 1 = VS Code, 2 = VS, 3 = Rider, 4 = Custom, ...
        # We ship an editor_settings file so first launch already points at VSCode.
        editorSettings = pkgs.writeText "editor_settings-4.tres" ''
          [gd_resource type="EditorSettings" format=3]

          [resource]
          dotnet/editor/external_editor = 1
          dotnet/editor/custom_exec_path = "${vscode}/bin/code"
          dotnet/editor/custom_exec_path_args = "{project} --goto {file}:{line}:{col}"
          mono/editor/external_editor = 1
        '';

        godot-mono = pkgs.writeShellApplication {
          name = "godot-mono";
          runtimeInputs = [ pkgs.godot-mono dotnet vscode ];
          text = ''
            export DOTNET_ROOT="${dotnet}"
            export DOTNET_CLI_TELEMETRY_OPTOUT=1
            export PATH="${dotnet}/bin:${vscode}/bin:$PATH"

            # Seed VSCode as external editor if the user has no config yet.
            cfg="''${XDG_CONFIG_HOME:-$HOME/.config}/godot"
            mkdir -p "$cfg"
            if [ ! -e "$cfg/editor_settings-4.tres" ]; then
              cp "${editorSettings}" "$cfg/editor_settings-4.tres"
              chmod u+w "$cfg/editor_settings-4.tres"
            fi

            exec godot-mono "$@"
          '';
        };
      in
      {
        packages.default = godot-mono;
        apps.default = flake-utils.lib.mkApp { drv = godot-mono; };
      });
}
