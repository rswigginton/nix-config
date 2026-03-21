{ pkgs, ... }:
{
  imports = [
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
      "libvirtd"
    ];
    shell = pkgs.fish;
  };

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    vivaldi
    slack
    zoom
  ];

  # System state version
  system.stateVersion = "25.11";
}
