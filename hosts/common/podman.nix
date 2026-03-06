{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    distrobox
    lazydocker
    podman-compose
    (writeShellScriptBin "docker-compose" ''exec podman compose "$@"'')
  ];

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
