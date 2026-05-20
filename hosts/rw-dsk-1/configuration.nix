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
    ../common/zsh.nix
    ../common/docker.nix
    ../common/steam.nix
    # ../common/cosmic.nix
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

  # Wake-on-LAN (magic packet) — NM manages eno1 so the
  # networking.interfaces.*.wakeOnLan option is a no-op here.
  # Force WOL on at boot and after resume via ethtool.
  systemd.services.wol-eno1 = {
    description = "Enable Wake-on-LAN for eno1";
    wantedBy = [
      "multi-user.target"
      "suspend.target"
      "hibernate.target"
    ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s eno1 wol g";
    };
  };

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
    shell = pkgs.zsh;
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
    ethtool
    wakeonlan
  ];

  # System state version
  system.stateVersion = "25.11";
}
