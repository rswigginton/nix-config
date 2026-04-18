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
    ../common/cosmic.nix
    ../common/docker.nix
    ./hardware-configuration.nix
  ];

  boot.kernelParams = [
    "video=Virtual-1:3440x1440@60"
  ];

  # Bootloader — auto-detected, verify this is correct
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "rw-pl-vm";

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
    ferdium
  ];

  # Enable home-manager for the robert user
  home-manager.users = {
    robert = import ../../home/robert/rw-pl-vm.nix;
  };

  # System state version
  system.stateVersion = "25.11";
}
