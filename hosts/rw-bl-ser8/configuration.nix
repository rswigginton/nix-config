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
    ../common/desktop.nix
    ../common/fish.nix
    # ../common/podman.nix
    ../common/docker.nix
    ../common/cosmic.nix
    ../common/virt-manager.nix
    ../common/keyboards.nix
    ../common/tailscale.nix
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "rw-bl-ser8";

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
    acli
    vivaldi
    slack
    zoom-us
    cursor-cli
  ];

  # System state version
  system.stateVersion = "25.11";
}
