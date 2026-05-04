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
        # LOCAL_ROOT_URL is what Forgejo Actions embeds into job specs as the
        # clone URL. Defaults to "http://<HTTP_ADDR>:<HTTP_PORT>/" — which is
        # loopback inside job containers. Pin it to the public URL.
        LOCAL_ROOT_URL = "https://${forgejoDomain}/";
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

  # Inject custom navbar links into Forgejo via its template extension point.
  # See https://forgejo.org/docs/latest/admin/customization/ for other slots
  # (header.tmpl, footer.tmpl, home.tmpl, etc.). Materialized on every forgejo
  # start so the file is always in sync with what's declared here.
  systemd.services.forgejo.preStart =
    let
      extraLinks = pkgs.writeText "forgejo-extra-links.tmpl" ''
        <a class="item" href="{{AppSubUrl}}/robert/-/packages">
          {{svg "octicon-package"}} Packages
        </a>
      '';
    in
    lib.mkAfter ''
      # mkdir -p doesn't chmod when the dir already exists, so it's safe even
      # if a stale dir owned by another user is sitting there.
      mkdir -p /var/lib/forgejo/custom/templates/custom
      install -m 0644 ${extraLinks} \
        /var/lib/forgejo/custom/templates/custom/extra_links.tmpl
    '';

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
      # Use the public hostname: the runner itself + every job container needs
      # a reachable URL, and `127.0.0.1` would mean "the container itself"
      # inside a job. Traffic loops back: container -> host -> caddy -> forgejo.
      url = "https://${forgejoDomain}";
      tokenFile = "/var/lib/secrets/forgejo-runner-token";
      labels = [
        "ubuntu-latest:docker://node:20-bookworm"
        "ubuntu-22.04:docker://node:20-bookworm"
        # `docker` label needs node (for JS actions like actions/checkout)
        # AND docker CLI/compose. catthehacker/ubuntu:act-latest is the
        # canonical "GHA-compatible" image — ~1GB but cached after first pull.
        "docker:docker://catthehacker/ubuntu:act-latest"
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
          # Don't try to pull images that only exist locally on the host
          # daemon (e.g. built via `examples/ci-image/build.sh`). Falls back
          # to a pull if the image isn't already present.
          force_pull = false;
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
