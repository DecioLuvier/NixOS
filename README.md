# NixOS Configuration

1. Mount your disks normally
2. You must generate your own `hardware-configuration.nix` because it contains the disk layout and hardware-specific settings for your machine.

```
sudo nixos-generate-config --root /mnt
```

3. Install the system using this flake:

```
sudo nixos-install --flake github:decioluvier/nixos#default --no-write-lock-file
```

If the install fails, or if you pushed a new commit and the system is still using an old cached version, clear the Nix cache and run the install again:

```
rm -rf /home/$USER/.cache/nix
```