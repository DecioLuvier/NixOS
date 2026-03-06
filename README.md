# Installation

1. Clone this repository:
```
git clone https://github.com/decioluvier/nixos
cd nixos
```
2. Generate your hardware configuration:

```
sudo nixos-generate-config --root /mnt
git add /mnt/etc/nixos/hardware-configuration.nix
```
3. Install the system using the flake:

```
sudo nixos-install --flake /mnt/etc/nixos#default
```
