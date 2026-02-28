#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a fresh NixOS installation with this nix-config.
# Run this after a minimal NixOS install (with networking configured).
#
# Usage:
#   curl -sL <raw-url-to-this-script> | bash
#   # or copy/paste and run manually

REPO_URL="https://github.com/rswigginton/nix-config.git"
CLONE_DIR="$HOME/nix-config"

echo "=== NixOS Bootstrap ==="
echo ""

# 1. Enable flakes for this session (in case not yet configured)
export NIX_CONFIG="experimental-features = nix-command flakes"

# 2. Get git temporarily via nix-shell (fresh NixOS may not have it)
if ! command -v git &>/dev/null; then
  echo "Git not found, using nix-shell to provide it..."
  GIT="nix-shell -p git --run"
else
  GIT="eval"
fi

# 3. Clone the repo
if [[ -d "$CLONE_DIR" ]]; then
  echo "Directory $CLONE_DIR already exists, pulling latest..."
  $GIT "git -C $CLONE_DIR pull"
else
  echo "Cloning nix-config..."
  $GIT "git clone $REPO_URL $CLONE_DIR"
fi

# 4. Detect hostname or ask
HOSTNAME=$(hostname)
AVAILABLE_HOSTS=$(ls -d "$CLONE_DIR"/hosts/*/  2>/dev/null | xargs -n1 basename | grep -v common | tr '\n' ' ')

echo ""
echo "Available hosts: $AVAILABLE_HOSTS"
echo "Current hostname: $HOSTNAME"

if [[ ! -d "$CLONE_DIR/hosts/$HOSTNAME" ]]; then
  echo ""
  echo "No config found for hostname '$HOSTNAME'."
  echo "Either:"
  echo "  1. Rename this machine:  sudo hostnamectl set-hostname <name>"
  echo "  2. Create a new config:  cd $CLONE_DIR && ./scripts/add-host.sh $HOSTNAME"
  echo ""
  echo "Then re-run this script or proceed manually."
  exit 1
fi

# 5. Copy hardware config if missing
if [[ ! -f "$CLONE_DIR/hosts/$HOSTNAME/hardware-configuration.nix" ]]; then
  echo ""
  echo "Copying hardware-configuration.nix from current system..."
  if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
    cp /etc/nixos/hardware-configuration.nix "$CLONE_DIR/hosts/$HOSTNAME/"
    echo "Copied."
  else
    echo "WARNING: /etc/nixos/hardware-configuration.nix not found."
    echo "Generate it with: nixos-generate-config --show-hardware-config > $CLONE_DIR/hosts/$HOSTNAME/hardware-configuration.nix"
    exit 1
  fi
fi

# 6. Rebuild
echo ""
echo "Ready to rebuild. Running:"
echo "  sudo nixos-rebuild switch --flake $CLONE_DIR#$HOSTNAME"
echo ""
read -p "Proceed? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  sudo nixos-rebuild switch --flake "$CLONE_DIR#$HOSTNAME"
  echo ""
  echo "Done! You may want to reboot to ensure all changes take effect."
else
  echo ""
  echo "Skipped rebuild. When ready, run:"
  echo "  sudo nixos-rebuild switch --flake $CLONE_DIR#$HOSTNAME"
fi
