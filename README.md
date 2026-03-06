# Installation

1. Clone this repository:
```
sudo git clone https://github.com/decioluvier/nixos
cd nixos
```
2. Generate your hardware configuration:
```
sudo nixos-generate-config --root /mnt
sudo git add /mnt/etc/nixos/hardware-configuration.nix -f
```
3. Install the system using the flake:
```
sudo nixos-install --flake /mnt/etc/nixos#default
```

cd /etc/nixos
sudo git pull
sudo nixos-rebuild switch --flake /etc/nixos#default