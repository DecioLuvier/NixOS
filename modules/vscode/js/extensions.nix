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
  dbaeumer.vscode-eslint
  esbenp.prettier-vscode
  bradlc.vscode-tailwindcss
  prisma.prisma
  dotenv.dotenv-vscode
  humao.rest-client
] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
  {
    name = "es7-react-js-snippets";
    publisher = "dsznajder";
    version = "4.4.3";
    sha256 = "sha256:1ilzisfykf60a700bbwvpl1a9rcqy6flkzpp8d8knyj86y3amacr";
  }
]
