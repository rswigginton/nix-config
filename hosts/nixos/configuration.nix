{ ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader (GRUB for VM)
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  # Hostname
  networking.hostName = "nixos";

  # QEMU guest support for VM
  services.qemuGuest.enable = true;

  # System state version
  system.stateVersion = "25.11";
}
