#!/usr/bin/env bash
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/DecioLuvier/NixOS/main/hosts/laptop/install.sh)" -- /dev/sdX [swapSize]

set -euo pipefail

DISK="${1:-}"
SWAP_SIZE="${2:-8G}"
REPO="${REPO:-https://github.com/DecioLuvier/NixOS}"
BRANCH="${BRANCH:-main}"
FLAKE="${FLAKE:-laptop}"

case "$DISK" in
  *[0-9]) PART="${DISK}p" ;;
  *)      PART="${DISK}" ;;
esac
ESP="${PART}1"
SWAP="${PART}2"
ROOT="${PART}3"

wipefs -a "$DISK"
sgdisk --zap-all "$DISK"
sgdisk -n1:0:+1GiB        -t1:ef00 -c1:BOOT  "$DISK"
sgdisk -n2:0:+"$SWAP_SIZE" -t2:8200 -c2:swap  "$DISK"
sgdisk -n3:0:0            -t3:8300 -c3:nixos "$DISK"
partprobe "$DISK"
sleep 2

mkfs.vfat -F32 -n BOOT "$ESP"
mkswap -L swap "$SWAP"
swapon "$SWAP"
mkfs.ext4 -F -L nixos "$ROOT"

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/BOOT /mnt/boot

rm -rf /mnt/etc/nixos
nix --extra-experimental-features 'nix-command flakes' \
  run nixpkgs#git -- clone --branch "$BRANCH" "$REPO" /mnt/etc/nixos

nixos-generate-config --root /mnt --show-hardware-config \
  > /mnt/etc/nixos/hosts/laptop/hardware.nix

nixos-install \
  --root /mnt \
  --flake "/mnt/etc/nixos#$FLAKE" \
  --no-root-passwd \
  --extra-experimental-features 'nix-command flakes'

nixos-enter --root /mnt -c 'passwd luvier'
