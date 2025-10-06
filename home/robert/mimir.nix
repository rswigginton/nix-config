{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [
    ./home.nix
    ../common
    ../features/cli
    ../features/desktop  # Desktop application configs
  ];

  # Specific configuration for mimir host
  home.username = "robert";
  home.homeDirectory = "/home/robert";
}