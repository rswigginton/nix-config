{ pkgs, ... }: {
  imports = [
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
    extraGroups = [ "networkmanager" "wheel" "podman" "libvirtd" ];
    shell = pkgs.fish;
  };

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    vivaldi
  ];

  # System state version
  system.stateVersion = "25.11";
}
