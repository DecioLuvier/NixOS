# Installation

1. Generate your hardware configuration:

```
sudo nixos-generate-config --root /mnt
```

2. Clone this repository:

```
git clone https://github.com/decioluvier/nixos
cd nixos
```

3. Copy your generated hardware configuration into the repository:

```
cp /mnt/etc/nixos/hardware-configuration.nix .
```

4. Install the system using the flake:

```
sudo nixos-install --flake .#default
```

## Updating the system

After installation, you can update the system with:

```
sudo nixos-rebuild switch --flake github:decioluvier/nixos
```
