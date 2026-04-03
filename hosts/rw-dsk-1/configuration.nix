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
    ../common/docker.nix
    ../common/steam.nix
    ../common/cosmic.nix
    # ../common/hyprland.nix
    # ../common/kde.nix
    ../common/virt-manager.nix
    ../common/keyboards.nix
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "rw-dsk-1";

  # User account
  users.users.robert = {
    isNormalUser = true;
    description = "Robert";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
      "docker"
      "libvirtd"
    ];
    shell = pkgs.fish;
  };

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    vivaldi
    zoom-us
  ];

  # Enable home-manager for the robert user
  home-manager.users = {
    robert = import ../../home/robert/rw-dsk-1.nix;
  };

  # System state version
  system.stateVersion = "25.11";
}
