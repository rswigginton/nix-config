# PLACEHOLDER — replace with the real hardware-configuration.nix from the
# target machine after install:
#
#   scp rw-forge:/etc/nixos/hardware-configuration.nix \
#       hosts/rw-forge/hardware-configuration.nix
#
# Or, on the target:
#   nixos-generate-config --show-hardware-config \
#     > hosts/rw-forge/hardware-configuration.nix
#
# `nix flake check` and `nixos-rebuild` will fail until this file is replaced.

{ ... }:
{
}
