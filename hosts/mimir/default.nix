{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [
    ../common
    ./configuration.nix
  ];

  # Enable home-manager for the robert user
  home-manager.users = {
    robert = import ../../home/robert/mimir.nix;
  };
}