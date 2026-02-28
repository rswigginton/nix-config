{ ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "rw-dsk-1";

  # System state version
  system.stateVersion = "25.11";
}
