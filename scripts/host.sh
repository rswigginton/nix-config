#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
  echo "Usage: $0 <command> <hostname>"
  echo ""
  echo "Commands:"
  echo "  add <hostname>      Scaffold a new NixOS host configuration"
  echo "  remove <hostname>   Remove an existing host configuration"
  echo "  list                List all configured hosts"
  exit 1
}

validate_hostname() {
  if [[ ! "$1" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo "Error: hostname must be lowercase, start with a letter, and contain only a-z, 0-9, hyphens"
    exit 1
  fi
}

list_hosts() {
  echo "Configured hosts:"
  for dir in "$REPO_ROOT"/hosts/*/; do
    name=$(basename "$dir")
    [[ "$name" == "common" ]] && continue
    echo "  $name"
  done
}

add_host() {
  local HOSTNAME="$1"
  validate_hostname "$HOSTNAME"

  if [[ -d "$REPO_ROOT/hosts/$HOSTNAME" ]]; then
    echo "Error: hosts/$HOSTNAME/ already exists"
    exit 1
  fi

  if [[ -f "$REPO_ROOT/home/robert/$HOSTNAME.nix" ]]; then
    echo "Error: home/robert/$HOSTNAME.nix already exists"
    exit 1
  fi

  echo "Creating host: $HOSTNAME"

  # --- hosts/<hostname>/configuration.nix ---
  mkdir -p "$REPO_ROOT/hosts/$HOSTNAME"

  # Detect bootloader type
  if [[ -d /sys/firmware/efi ]]; then
    BOOTLOADER_CONFIG="  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;"
  else
    # Find the disk device that holds the root filesystem
    ROOT_PART=$(findmnt -no SOURCE /)
    BOOT_DISK=$(lsblk -ndo PKNAME "$ROOT_PART" 2>/dev/null | head -1)
    BOOT_DISK="/dev/${BOOT_DISK:-sda}"
    BOOTLOADER_CONFIG="  boot.loader.grub.enable = true;
  boot.loader.grub.device = \"$BOOT_DISK\";"
  fi

  cat > "$REPO_ROOT/hosts/$HOSTNAME/configuration.nix" << NIXEOF
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ../common
    ./hardware-configuration.nix
  ];

  # Bootloader — auto-detected, verify this is correct
${BOOTLOADER_CONFIG}

  # Hostname
  networking.hostName = "$HOSTNAME";

  # User account
  users.users.robert = {
    isNormalUser = true;
    description = "Robert";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  # Host-specific packages
  environment.systemPackages = with pkgs; [
  ];

  # Enable home-manager for the robert user
  home-manager.users = {
    robert = import ../../home/robert/$HOSTNAME.nix;
  };

  # System state version
  system.stateVersion = "25.11";
}
NIXEOF

  # --- home/robert/<hostname>.nix ---
  cat > "$REPO_ROOT/home/robert/$HOSTNAME.nix" << 'NIXEOF'
{ ... }:
{
  imports = [
    ./home.nix
    ../common.nix
    ../git.nix
  ];
}
NIXEOF

  # --- Patch flake.nix ---
  sed -i "/nixosConfigurations = {/,/};/ {
    /};/ i\\        $HOSTNAME = mkHost \"$HOSTNAME\";
  }" "$REPO_ROOT/flake.nix"

  sed -i "/homeConfigurations = {/,/};/ {
    /};/ i\\        \"robert@$HOSTNAME\" = mkHome \"$HOSTNAME\";
  }" "$REPO_ROOT/flake.nix"

  # Stage new files so Nix flakes can see them (flakes ignore untracked files)
  git -C "$REPO_ROOT" add \
    "hosts/$HOSTNAME/configuration.nix" \
    "home/robert/$HOSTNAME.nix" \
    flake.nix

  echo ""
  echo "Done! Created:"
  echo "  hosts/$HOSTNAME/configuration.nix"
  echo "  home/robert/$HOSTNAME.nix"
  echo "  Updated flake.nix"
  echo ""
  echo "Next steps:"
  echo "  1. Copy hardware-configuration.nix from the target machine:"
  echo "     scp $HOSTNAME:/etc/nixos/hardware-configuration.nix hosts/$HOSTNAME/"
  echo "     (or run 'nixos-generate-config --show-hardware-config' on the target)"
  echo "  2. Review and customize hosts/$HOSTNAME/configuration.nix"
  echo "  3. Review and customize home/robert/$HOSTNAME.nix"
  echo "  4. Validate: nix flake check"
  echo "  5. Deploy: sudo nixos-rebuild switch --flake .#$HOSTNAME"
}

remove_host() {
  local HOSTNAME="$1"
  validate_hostname "$HOSTNAME"

  if [[ "$HOSTNAME" == "common" ]]; then
    echo "Error: cannot remove 'common'"
    exit 1
  fi

  # Prevent removing the host you're currently running on
  CURRENT_HOST=$(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo "")
  if [[ "$HOSTNAME" == "$CURRENT_HOST" ]]; then
    echo "Error: refusing to remove '$HOSTNAME' — you're currently running on this host"
    exit 1
  fi

  if [[ ! -d "$REPO_ROOT/hosts/$HOSTNAME" ]]; then
    echo "Error: hosts/$HOSTNAME/ does not exist"
    exit 1
  fi

  echo "This will remove:"
  echo "  hosts/$HOSTNAME/"
  [[ -f "$REPO_ROOT/home/robert/$HOSTNAME.nix" ]] && echo "  home/robert/$HOSTNAME.nix"
  echo "  flake.nix entries for $HOSTNAME"
  echo ""
  read -p "Proceed? [y/N] " -n 1 -r
  echo ""

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi

  # Remove host directory
  rm -rf "${REPO_ROOT:?}/hosts/$HOSTNAME"

  # Remove home config
  rm -f "$REPO_ROOT/home/robert/$HOSTNAME.nix"

  # Remove from flake.nix
  sed -i "/^[[:space:]]*$HOSTNAME = mkHost \"$HOSTNAME\";$/d" "$REPO_ROOT/flake.nix"
  sed -i "/^[[:space:]]*\"robert@$HOSTNAME\" = mkHome \"$HOSTNAME\";$/d" "$REPO_ROOT/flake.nix"

  # Stage removals
  git -C "$REPO_ROOT" add -A "hosts/$HOSTNAME" "home/robert/$HOSTNAME.nix" flake.nix

  echo ""
  echo "Done! Removed host '$HOSTNAME'."
  echo "Run 'nix flake check' to validate."
}

# --- Main ---
if [[ $# -lt 1 ]]; then
  usage
fi

COMMAND="$1"
shift

case "$COMMAND" in
  add)
    [[ $# -ne 1 ]] && usage
    add_host "$1"
    ;;
  remove)
    [[ $# -ne 1 ]] && usage
    remove_host "$1"
    ;;
  list)
    list_hosts
    ;;
  *)
    usage
    ;;
esac
