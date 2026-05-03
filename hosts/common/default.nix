# Shared base for all hosts (server + desktop).
# Desktop-only bits live in ./desktop.nix — desktop hosts must import both.

{
  lib,
  inputs,
  outputs,
  pkgs,
  ...
}:
{

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "America/Denver";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  console.keyMap = "us";

  # Security
  security.sudo.wheelNeedsPassword = false;

  # Minimal CLI toolset shared by every host
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    btop
    jq
    yq
    ripgrep
    fd
    tree
    file
    which
    unzip
    zip
    gnumake
    openssl
    dig
    nmap
    traceroute
  ];

  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  environment.variables.EDITOR = "vim";
  environment.variables.VISUAL = "vim";

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.robert.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBn3PEGOE8XR72+c5gnhnYnj3rrGoBXFhqEq086VU0Ep robert-personal"
  ];

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        "robert"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
      (lib.filterAttrs (_: lib.isType "flake")) inputs
    );
    nixPath = [ "/etc/nix/path" ];
  };
}
