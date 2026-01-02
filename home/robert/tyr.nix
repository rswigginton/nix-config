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

  # Enable CLI features
  features.cli = {
    fish.enable = true;
    atuin.enable = true;
    starship.enable = true;
  };
  
  # Enable desktop features
  features.desktop = {
    firefox.enable = true;
  };
}
