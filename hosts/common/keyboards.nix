{ pkgs, ... }: {
  # QMK firmware
  hardware.keyboard.qmk.enable = true;
  environment.systemPackages = [ pkgs.qmk ];

  # ZSA keyboards (Ergodox EZ, Planck EZ, Moonlander, Voyager)
  hardware.keyboard.zsa.enable = true;

  # Vial firmware udev rule
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
}
