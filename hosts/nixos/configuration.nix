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
    ../common/podman.nix
    # ../common/cosmic.nix
    ../common/hyprland.nix
    ../common/virt-manager.nix
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
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
    shell = pkgs.fish;
  };

  # QEMU/KVM guest services
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

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
