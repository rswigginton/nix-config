{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:

let
  forgejoDomain = "git.trebornaut.com";
  woodpeckerDomain = "woodpecker.trebornaut.com";
  forgejoHttpPort = 3000;
  woodpeckerHttpPort = 8000;
  woodpeckerGrpcPort = 9000;
in
{
  imports = [
    ../common
    ../common/fish.nix
    ../common/docker.nix
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "rw-forge";

  # User account
  users.users.robert = {
    isNormalUser = true;
    description = "Robert";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.fish;
  };

  # Firewall: HTTPS, HTTP (ACME challenge), Forgejo SSH
  networking.firewall.allowedTCPPorts = [
    80
    443
    2222
  ];

  # ---------------------------------------------------------------------------
  # Forgejo
  # ---------------------------------------------------------------------------
  services.forgejo = {
    enable = true;
    database.type = "sqlite3";
    lfs.enable = true;

    settings = {
      DEFAULT.APP_NAME = "trebornaut git";

      server = {
        DOMAIN = forgejoDomain;
        ROOT_URL = "https://${forgejoDomain}/";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = forgejoHttpPort;
        # Forgejo's built-in SSH server; host's openssh stays on 22.
        START_SSH_SERVER = true;
        SSH_PORT = 2222;
        SSH_LISTEN_PORT = 2222;
        SSH_DOMAIN = forgejoDomain;
      };

      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
  };

  # ---------------------------------------------------------------------------
  # Woodpecker
  # ---------------------------------------------------------------------------
  #
  # Secrets live in /var/lib/secrets/woodpecker.env (root:root, 0600).
  # Required keys:
  #   WOODPECKER_FORGEJO_CLIENT=<oauth2 client id from forgejo>
  #   WOODPECKER_FORGEJO_SECRET=<oauth2 client secret from forgejo>
  #   WOODPECKER_AGENT_SECRET=<long random string, shared server<->agent>
  #
  # Generate agent secret with: openssl rand -hex 32
  # Create OAuth app in Forgejo: Site Administration -> Applications.
  #   Redirect URI: https://woodpecker.trebornaut.com/authorize
  #
  # The same file is reused for the agent (only WOODPECKER_AGENT_SECRET is
  # consumed there). Keep it 0600 root-owned; both services run as root or
  # systemd dynamic users that read it before privilege drop.
  services.woodpecker-server = {
    enable = true;
    environment = {
      WOODPECKER_HOST = "https://${woodpeckerDomain}";
      WOODPECKER_SERVER_ADDR = "127.0.0.1:${toString woodpeckerHttpPort}";
      WOODPECKER_GRPC_ADDR = "127.0.0.1:${toString woodpeckerGrpcPort}";
      WOODPECKER_OPEN = "false";
      WOODPECKER_FORGEJO = "true";
      WOODPECKER_FORGEJO_URL = "https://${forgejoDomain}";
      WOODPECKER_DATABASE_DRIVER = "sqlite3";
      WOODPECKER_DATABASE_DATASOURCE = "/var/lib/woodpecker-server/woodpecker.sqlite";
    };
    environmentFile = "/var/lib/secrets/woodpecker.env";
  };

  services.woodpecker-agents.agents.docker = {
    enable = true;
    environment = {
      WOODPECKER_SERVER = "127.0.0.1:${toString woodpeckerGrpcPort}";
      WOODPECKER_BACKEND = "docker";
      DOCKER_HOST = "unix:///var/run/docker.sock";
      WOODPECKER_MAX_WORKFLOWS = "4";
    };
    environmentFile = [ "/var/lib/secrets/woodpecker.env" ];
    extraGroups = [ "docker" ];
  };

  # ---------------------------------------------------------------------------
  # ACME (lego) + Caddy reverse proxy
  # ---------------------------------------------------------------------------
  #
  # lego (via security.acme) issues certs over DNS-01 using Cloudflare, and
  # drops them at /var/lib/acme/<domain>/. Stock pkgs.caddy reads those files
  # directly — no caddy plugin build needed.
  #
  # Secrets file: /var/lib/secrets/cloudflare-acme.env (root:root, 0600)
  # Required key:
  #   CLOUDFLARE_DNS_API_TOKEN=<scoped API token>
  #
  # Create the token at https://dash.cloudflare.com/profile/api-tokens with
  # permissions: Zone:Read + DNS:Edit, scoped to the trebornaut.com zone.
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "rswigginton@gmail.com";
      dnsProvider = "cloudflare";
      credentialsFile = "/var/lib/secrets/cloudflare-acme.env";
      # Use a public resolver so we don't depend on the host's DNS for the
      # propagation check.
      dnsResolver = "1.1.1.1:53";
      # caddy needs to read the key files; run lego with the caddy group so
      # the resulting certs are group-readable by caddy.
      group = "caddy";
      reloadServices = [ "caddy.service" ];
    };
    certs = {
      ${forgejoDomain} = { };
      ${woodpeckerDomain} = { };
    };
  };

  services.caddy = {
    enable = true;
    email = "rswigginton@gmail.com";

    virtualHosts.${forgejoDomain}.extraConfig = ''
      tls /var/lib/acme/${forgejoDomain}/fullchain.pem /var/lib/acme/${forgejoDomain}/key.pem
      reverse_proxy 127.0.0.1:${toString forgejoHttpPort}
    '';

    virtualHosts.${woodpeckerDomain}.extraConfig = ''
      tls /var/lib/acme/${woodpeckerDomain}/fullchain.pem /var/lib/acme/${woodpeckerDomain}/key.pem
      reverse_proxy 127.0.0.1:${toString woodpeckerHttpPort}
    '';
  };

  # Don't start caddy until certs exist; otherwise first boot fails because
  # the tls files aren't there yet.
  systemd.services.caddy = {
    after = [
      "acme-finished-${forgejoDomain}.target"
      "acme-finished-${woodpeckerDomain}.target"
    ];
    wants = [
      "acme-finished-${forgejoDomain}.target"
      "acme-finished-${woodpeckerDomain}.target"
    ];
  };

  # Host-specific packages
  environment.systemPackages = with pkgs; [
  ];

  # System state version
  system.stateVersion = "25.11";
}
