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
  forgejoHttpPort = 3000;

  woodpeckerDomain = "ci.trebornaut.com";
  woodpeckerHttpPort = 8000;
  woodpeckerGrpcPort = 9000;

  tailscaleAdvertise = "192.168.1.0/24";
in
{
  imports = [
    ../common
    ../common/fish.nix
    ../common/docker.nix
    ../common/tailscale.nix
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "rw-util-1";

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

  # Firewall: HTTPS, HTTP (ACME http-01 fallback / redirects), Forgejo SSH.
  # Tailscale handles its own port via services.tailscale.
  networking.firewall.allowedTCPPorts = [
    80
    443
    2222
  ];

  # ---------------------------------------------------------------------------
  # Tailscale subnet router
  # ---------------------------------------------------------------------------
  #
  # services.tailscale is enabled via ../common/tailscale.nix. To actually
  # advertise the LAN, run once after first boot + tailscale auth:
  #
  #   sudo tailscale up --advertise-routes=${tailscaleAdvertise} \
  #     --accept-dns=false
  #
  # Then approve the route in the tailscale admin console:
  #   https://login.tailscale.com/admin/machines → this host → Edit route settings
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  services.tailscale.useRoutingFeatures = "server";

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
        LOCAL_ROOT_URL = "https://${forgejoDomain}/";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = forgejoHttpPort;
        START_SSH_SERVER = true;
        SSH_PORT = 2222;
        SSH_LISTEN_PORT = 2222;
        SSH_DOMAIN = forgejoDomain;
      };

      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;

      "cron.cleanup_offline_runners" = {
        ENABLED = true;
        RUN_AT_START = true;
        SCHEDULE = "@hourly";
        GLOBAL_SCOPE_ONLY = true;
        OLDER_THAN = "1h";
      };
    };

    # ---------------------------------------------------------------------------
    # Forgejo backup → Cloudflare R2
    # ---------------------------------------------------------------------------
    #
    # 1. forgejo's dump module writes a tar.zst to /var/lib/forgejo/dump/
    #    on the configured interval (sqlite snapshot, repos, lfs, attachments).
    # 2. systemd timer below rclone-copies the latest dump to R2.
    #
    # rclone config secret: /var/lib/secrets/rclone-r2.conf (root:root, 0600)
    #   [r2]
    #   type = s3
    #   provider = Cloudflare
    #   access_key_id = <R2 access key>
    #   secret_access_key = <R2 secret>
    #   endpoint = https://<account-id>.r2.cloudflarestorage.com
    #   region = auto
    dump = {
      enable = true;
      # 3am America/Denver (system tz, set in common/default.nix).
      interval = "*-*-* 03:00:00";
      type = "tar.zst";
      backupDir = "/var/lib/forgejo/dump";
    };
  };

  # Trigger upload only when the dump finishes successfully — no own timer,
  # no race against a still-running dump. forgejo-dump.service is created by
  # the forgejo module; we add an OnSuccess hook to it.
  systemd.services.forgejo-dump.unitConfig.OnSuccess = [ "forgejo-dump-upload.service" ];

  # Healthchecks.io ping URL at /var/lib/secrets/healthchecks.env (0600):
  #   HC_FORGEJO_BACKUP_URL=https://hc-ping.com/<uuid>
  systemd.services.forgejo-dump-upload = {
    description = "Upload latest forgejo dump to Cloudflare R2";
    after = [ "forgejo-dump.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      EnvironmentFile = "/var/lib/secrets/healthchecks.env";
      ExecStart = pkgs.writeShellScript "forgejo-dump-upload" ''
        set -euo pipefail
        ${pkgs.rclone}/bin/rclone \
          --config /var/lib/secrets/rclone-r2.conf \
          copy /var/lib/forgejo/dump/ r2:trebornaut-backups/forgejo/ \
          --include "*.tar.zst"
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "$HC_FORGEJO_BACKUP_URL" >/dev/null
      '';
      # Ping /fail if the unit exits non-zero so a missed check fires alert.
      ExecStopPost = pkgs.writeShellScript "forgejo-dump-upload-failhook" ''
        if [ "$EXIT_STATUS" != "0" ]; then
          ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "$HC_FORGEJO_BACKUP_URL/fail" \
            >/dev/null || true
        fi
      '';
    };
  };

  # ---------------------------------------------------------------------------
  # Local dump prune (gated on R2 freshness)
  # ---------------------------------------------------------------------------
  #
  # Refuses to delete anything if R2 doesn't have a backup uploaded within the
  # last 2 days. Keeps local backups around as a safety net when the upload
  # pipeline silently stops working.
  systemd.services.forgejo-dump-prune-local = {
    description = "Prune local forgejo dumps if R2 has a recent backup";
    after = [ "forgejo-dump-upload.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = pkgs.writeShellScript "forgejo-dump-prune-local" ''
        set -euo pipefail
        RCLONE='${pkgs.rclone}/bin/rclone --config /var/lib/secrets/rclone-r2.conf'

        # Newest mtime in R2, ISO format from rclone lsl ("YYYY-MM-DD HH:MM:SS").
        latest=$($RCLONE lsl r2:trebornaut-backups/forgejo/ --include '*.tar.zst' \
          | awk '{print $2" "$3}' | sort | tail -1 || true)

        if [ -z "$latest" ]; then
          echo "no R2 backups found — refusing to prune local"
          exit 1
        fi

        latest_epoch=$(${pkgs.coreutils}/bin/date -d "$latest" +%s)
        now=$(${pkgs.coreutils}/bin/date +%s)
        age_days=$(( (now - latest_epoch) / 86400 ))

        if [ "$age_days" -gt 2 ]; then
          echo "newest R2 backup is $age_days days old — refusing to prune local"
          exit 1
        fi

        echo "R2 fresh ($age_days days old), pruning local dumps older than 14 days"
        ${pkgs.findutils}/bin/find /var/lib/forgejo/dump \
          -name '*.tar.zst' -mtime +14 -print -delete
      '';
    };
  };

  systemd.timers.forgejo-dump-prune-local = {
    description = "Weekly local dump prune (gated on R2 freshness)";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  # ---------------------------------------------------------------------------
  # Forgejo Actions runner (docker backend)
  # ---------------------------------------------------------------------------
  #
  # Token file: /var/lib/secrets/forgejo-runner-token (root:root, 0600).
  # Generate after first forgejo start with:
  #   sudo -u forgejo forgejo --work-path /var/lib/forgejo \
  #     actions generate-runner-token \
  #     | sudo tee /var/lib/secrets/forgejo-runner-token > /dev/null
  #   sudo chmod 600 /var/lib/secrets/forgejo-runner-token
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.default = {
      enable = true;
      name = "rw-util-1-default";
      url = "https://${forgejoDomain}";
      tokenFile = "/var/lib/secrets/forgejo-runner-token";
      labels = [
        "ubuntu-latest:docker://node:20-bookworm"
        "ubuntu-22.04:docker://node:20-bookworm"
      ];
      settings = {
        runner.capacity = 4;
        container = {
          docker_host = "unix:///var/run/docker.sock";
          force_pull = false;
        };
      };
    };
  };

  systemd.services."gitea-runner-default".serviceConfig.SupplementaryGroups = [ "docker" ];

  # ---------------------------------------------------------------------------
  # Woodpecker CI (server + agent, both pointed at this host's forgejo)
  # ---------------------------------------------------------------------------
  #
  # Two-stage setup (chicken-egg with forgejo OAuth):
  #   1. Boot host, finish forgejo setup, sign in.
  #   2. Forgejo → Site Administration → Integrations → OAuth2 Applications
  #      → New: name "woodpecker", redirect URI
  #      https://${woodpeckerDomain}/authorize
  #   3. Drop creds at /var/lib/secrets/woodpecker.env (root:root, 0600):
  #        WOODPECKER_FORGEJO_CLIENT=<client id from step 2>
  #        WOODPECKER_FORGEJO_SECRET=<client secret from step 2>
  #        WOODPECKER_AGENT_SECRET=<openssl rand -hex 32>
  #   4. systemctl restart woodpecker-server woodpecker-agent-docker
  services.woodpecker-server = {
    enable = true;
    environment = {
      WOODPECKER_HOST = "https://${woodpeckerDomain}";
      WOODPECKER_SERVER_ADDR = "127.0.0.1:${toString woodpeckerHttpPort}";
      WOODPECKER_GRPC_ADDR = "127.0.0.1:${toString woodpeckerGrpcPort}";
      WOODPECKER_OPEN = "true";
      WOODPECKER_ADMIN = "robert";

      WOODPECKER_FORGEJO = "true";
      WOODPECKER_FORGEJO_URL = "https://${forgejoDomain}";

      WOODPECKER_DATABASE_DRIVER = "sqlite3";
      WOODPECKER_DATABASE_DATASOURCE = "/var/lib/woodpecker-server/woodpecker.sqlite";
    };
    environmentFile = "/var/lib/secrets/woodpecker.env";
  };

  services.woodpecker-agents.agents.docker = {
    enable = true;
    extraGroups = [ "docker" ];
    environment = {
      WOODPECKER_SERVER = "127.0.0.1:${toString woodpeckerGrpcPort}";
      WOODPECKER_BACKEND = "docker";
      DOCKER_HOST = "unix:///var/run/docker.sock";
      WOODPECKER_MAX_WORKFLOWS = "4";
    };
    environmentFile = [ "/var/lib/secrets/woodpecker.env" ];
  };

  # ---------------------------------------------------------------------------
  # ACME (lego, cloudflare DNS-01) + Caddy
  # ---------------------------------------------------------------------------
  #
  # Same pattern as rw-forge: lego writes certs to /var/lib/acme/<domain>/,
  # stock pkgs.caddy reads them directly. No custom caddy plugin build.
  #
  # Secrets file: /var/lib/secrets/cloudflare-acme.env (root:root, 0600)
  #   CLOUDFLARE_DNS_API_TOKEN=<scoped token, Zone:Read + DNS:Edit>
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "rswigginton@gmail.com";
      dnsProvider = "cloudflare";
      environmentFile = "/var/lib/secrets/cloudflare-acme.env";
      dnsResolver = "1.1.1.1:53";
      reloadServices = [ "caddy.service" ];
    };
    certs = {
      ${forgejoDomain} = { };
      ${woodpeckerDomain} = { };
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

    virtualHosts.${woodpeckerDomain}.extraConfig = ''
      tls /var/lib/acme/${woodpeckerDomain}/fullchain.pem /var/lib/acme/${woodpeckerDomain}/key.pem
      reverse_proxy 127.0.0.1:${toString woodpeckerHttpPort}
    '';
  };

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
    forgejo
    woodpecker-cli
  ];

  system.stateVersion = "25.11";
}
