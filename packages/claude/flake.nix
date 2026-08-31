{
  description = "Claude Code + Playwright MCP";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        mcpConfig = builtins.toJSON {
          mcpServers.playwright = {
            command = "npx";
            args = [
              "-y"
              "@playwright/mcp@latest"
              "--browser"
              "firefox"
              "--executable-path"
              "${pkgs.lib.getExe pkgs.firefox}"
            ];
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            claude-code
            nodejs_20
            firefox
            playwright-driver.browsers
          ];

          PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
          PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";

          shellHook = ''
            echo '${mcpConfig}' > .mcp.json
            exec ${pkgs.lib.getExe pkgs.claude-code}
          '';
        };
      }
    );
}