{ inputs, system }:

let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };
in
with pkgs.vscode-extensions; [
  dracula-theme.theme-dracula
  bradlc.vscode-tailwindcss
  prisma.prisma
  astro-build.astro-vscode
] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
  {
    name = "es7-react-js-snippets";
    publisher = "dsznajder";
    version = "4.4.3";
    sha256 = "sha256-QF950JhvVIathAygva3wwUOzBLjBm7HE3Sgcp7f20Pc=";
  }
]
