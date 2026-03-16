# NOTE: The default libvirt network must be started imperatively:
#   sudo virsh net-start default
#   sudo virsh net-autostart default
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
  ];

  programs.virt-manager.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };


  virtualisation.spiceUSBRedirection.enable = true;

  programs.dconf.enable = true;
}
