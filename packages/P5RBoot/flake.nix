{
  description = "P5RBoot: GRUB com fundo dinamico por entry (Persona 5 Royal) via GRUB patcheado";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      config.nixpkgs.overlays = [
        (final: prev: {
          grub2 = prev.grub2.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [ ./background.patch ];
          });
        })
      ];

      config.boot.loader = {
        systemd-boot.enable      = false;
        efi.canTouchEfiVariables = true;
        grub = {
          enable       = true;
          efiSupport   = true;
          device       = "nodev";
          useOSProber  = false;
          gfxmodeEfi     = "1366x768,auto";
          gfxmodeBios    = "1366x768,auto";
          backgroundColor = "#000000";
          extraConfig  = ''
            insmod gfxterm
            insmod png
          '';

          entryOptions    = "--class 1 --unrestricted";
          subEntryOptions = "--class 3";

          theme = pkgs.runCommand "mikuboot-grub-theme" { } ''
            mkdir -p $out
            cp -r ${./theme}/* $out/
          '';

          extraEntries = ''
            menuentry "UEFI" --class 2 {
              fwsetup
            }
          '';
        };
      };
    };
  };
}
