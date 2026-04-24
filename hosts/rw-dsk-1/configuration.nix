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
    ../common/hyprland.nix
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
      "plugdev"
    ];
    shell = pkgs.fish;
  };

  services.input-remapper.enable = true;

  # Allow input-remapper pkexec without auth agent (NixOS store path
  # doesn't match /usr/bin in the upstream polkit policy)
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id === "org.freedesktop.policykit.exec" &&
          action.lookup("program").indexOf("input-remapper") !== -1 &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    vivaldi
    zoom-us
    discord-ptb
  ];

  # Enable home-manager for the robert user
  home-manager.users = {
    robert = import ../../home/robert/rw-dsk-1.nix;
  };

  # System state version
  system.stateVersion = "25.11";
}
