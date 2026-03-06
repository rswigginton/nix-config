{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.distrobox
    pkgs.podman-compose
  ];
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
