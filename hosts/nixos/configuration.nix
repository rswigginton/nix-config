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

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "nixos";

  # User account
  users.users.robert = {
    isNormalUser = true;
    description = "Robert";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    #shell = pkgs.fish;
  };

  # Host-specific packages
  environment.systemPackages = with pkgs; [
  ];

  # Enable home-manager for the robert user
  home-manager.users = {
    robert = import ../../home/robert/nixos.nix;
  };

  # System state version
  system.stateVersion = "25.11";
}
