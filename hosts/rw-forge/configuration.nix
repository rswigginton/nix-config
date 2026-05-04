{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:

let
  forgejoDomain = "git2.trebornaut.com";
  forgejoHttpPort = 3000;
in
{
  imports = [
    ../common
    ../common/fish.nix
    ../common/docker.nix
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
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

      # Auto-prune runner records that have been offline for a while —
      # cleans up the stale entries created when a runner re-registers
      # (e.g. after a labels change wipes its .runner credential).
      "cron.cleanup_offline_runners" = {
        ENABLED = true;
        RUN_AT_START = true;
        SCHEDULE = "@hourly";
        GLOBAL_SCOPE_ONLY = true;
        OLDER_THAN = "1h";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Forgejo Actions runners (docker backend, ephemeral per job)
  # ---------------------------------------------------------------------------
  #
  # Token file: /var/lib/secrets/forgejo-runner-token (root:root, 0600).
  # Generate once with:
  #   sudo -u forgejo forgejo --work-path /var/lib/forgejo \
  #     actions generate-runner-token \
  #     | sudo tee /var/lib/secrets/forgejo-runner-token > /dev/null
  #   sudo chmod 600 /var/lib/secrets/forgejo-runner-token
  #
  # The same registration token is reusable across all instances; each runner
  # mints its own per-runner credential on first connect (~/.runner inside the
  # state dir) and stops needing the token file thereafter.
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.default = {
      enable = true;
      name = "rw-forge-default";
      # Loopback to forgejo — no DNS / TLS in the hot path.
      url = "http://127.0.0.1:${toString forgejoHttpPort}";
      tokenFile = "/var/lib/secrets/forgejo-runner-token";
      labels = [
        "ubuntu-latest:docker://node:20-bookworm"
        "ubuntu-22.04:docker://node:20-bookworm"
        # `docker` label uses an image with the docker CLI + compose plugin;
        # the host's docker socket is bind-mounted into the job container
        # below, so commands hit the host daemon.
        "docker:docker://docker:27-cli"
      ];
      settings = {
        runner.capacity = 4;
        container = {
          # `docker_host` set to the unix socket makes forgejo-runner auto-mount
          # /var/run/docker.sock into every job container. Workflows can then
          # run `docker compose up` etc. without privileged docker-in-docker.
          # Trade-off: jobs effectively have root on the host via docker —
          # only run trusted workflows.
          docker_host = "unix:///var/run/docker.sock";
        };
      };
    };
  };

  # The runner module uses DynamicUser; grant docker socket access via
  # supplementary group so jobs can spawn containers.
  systemd.services."gitea-runner-default".serviceConfig.SupplementaryGroups = [ "docker" ];

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
      environmentFile = "/var/lib/secrets/cloudflare-acme.env";
      # Use a public resolver so we don't depend on the host's DNS for the
      # propagation check.
      dnsResolver = "1.1.1.1:53";
      reloadServices = [ "caddy.service" ];
    };
    certs = {
      ${forgejoDomain} = { };
    };
  };

  users.users.caddy = {
    isSystemUser = true;
    group = "caddy";
    extraGroups = [ "acme" ];

  };
  users.groups.caddy = { };

  services.caddy = {
    enable = true;
    email = "rswigginton@gmail.com";

    virtualHosts.${forgejoDomain}.extraConfig = ''
      tls /var/lib/acme/${forgejoDomain}/fullchain.pem /var/lib/acme/${forgejoDomain}/key.pem
      reverse_proxy 127.0.0.1:${toString forgejoHttpPort}
    '';
  };

  # Don't start caddy until certs exist; otherwise first boot fails because
  # the tls files aren't there yet.
  systemd.services.caddy = {
    after = [ "acme-finished-${forgejoDomain}.target" ];
    wants = [ "acme-finished-${forgejoDomain}.target" ];
  };

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    forgejo
  ];

  # System state version
  system.stateVersion = "25.11";
}
