{
  description = "Claude Code + Playwright MCP + frontend-design & caveman plugins";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    frontend-design-src = {
      url = "github:anthropics/claude-code";
      flake = false;
    };
    caveman-src = {
      url = "github:juliusbrussee/caveman";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, frontend-design-src, caveman-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        chromiumBin = "${pkgs.lib.getExe pkgs.chromium}";

        frontendDesignPlugin = "${frontend-design-src}/plugins/frontend-design";
        cavemanPlugin = "${caveman-src}";

        mcpConfigFile = pkgs.writeText "mcp-config.json" (builtins.toJSON {
          mcpServers.playwright = {
            command = "npx";
            args = [
              "-y"
              "@playwright/mcp@latest"
              "--browser"
              "chromium"
              "--executable-path"
              chromiumBin
              "--headless"
            ];
          };
        });

        mkClaudePackage = { name, systemPrompt ? null }:
          pkgs.writeShellApplication {
            inherit name;
            excludeShellChecks = [ "SC2016" ];
            runtimeInputs = with pkgs; [
              claude-code
              nodejs_latest
              nix
              chromium
              playwright-driver.browsers
            ];
            text = ''
              export PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}"
              export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS="true"
              export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="true"

              exec claude \
                --permission-mode bypassPermissions \
                --strict-mcp-config --mcp-config "${mcpConfigFile}" \
                --plugin-dir "${frontendDesignPlugin}" \
                --plugin-dir "${cavemanPlugin}" \
                ${pkgs.lib.optionalString (systemPrompt != null)
                  "--append-system-prompt ${pkgs.lib.escapeShellArg systemPrompt}"} \
                "$@"
            '';
          };

        claudePackage = mkClaudePackage { name = "claude"; };

        claudeGtkPackage = mkClaudePackage {
          name = "claude";
          systemPrompt = ''
            - Run all commands inside 'nix develop'. 
            - Only modify files within the current folder. The app source is modules/main.cpp.
            - Use the frontend-design skill for every UI/UX, palette, typography, and GTK layout decision.
            - After any change: rebuild with 'dev-build', then clear stale Broadway run 'dev-broadway' in the background. 
            - Open localhost in the Broadway port, and inspect it with Playwright MCP, proving that the user instructions worked.
            - Stay in caveman mode (full) for all responses.
          '';
        };
      in
      {
        packages.default = claudePackage;
        packages.gtk = claudeGtkPackage;
      }
    );
}