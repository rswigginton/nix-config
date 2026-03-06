{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    distrobox
    lazydocker
    docker-compose
    podman-compose
    (writeShellScriptBin "docker-compose" ''exec docker compose "$@"'')
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
