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
    ../common/fish.nix
    ../common/podman.nix
    ../common/cosmic.nix
    ../common/virt-manager.nix
    ../common/keyboards.nix
    ../common/tailscale.nix
    ./configuration.nix
  ];

  # Enable home-manager for the robert user
  home-manager.users = {
    robert = import ../../home/robert/rw-bl-ser8.nix;
  };
}
