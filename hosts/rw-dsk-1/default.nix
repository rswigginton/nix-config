{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [
    ../common
    ../common/fish.nix
    ../common/podman.nix
    ./configuration.nix
  ];

  # Enable home-manager for the robert user
  home-manager.users = {
    robert = import ../../home/robert/rw-dsk-1.nix;
  };
}
