{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    distrobox
    lazydocker
    podman-compose
    podman-desktop
    kind
    (writeShellScriptBin "docker-compose" ''exec podman-compose "$@"'')
  ];

  environment.variables.DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock";

  virtualisation = {
    containers.enable = true;
    containers.registries.insecure = [ "localhost:5000" ];
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
