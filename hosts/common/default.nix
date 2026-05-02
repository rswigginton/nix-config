# Common configuration for all hosts

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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Security
  security.sudo.wheelNeedsPassword = false;

  # Display manager
  services.displayManager.ly.enable = true;

  # Common system packages for all hosts
  environment.systemPackages = with pkgs; [
    # Essential tools
    vim
    wget
    git
    curl
    chezmoi
    atuin

    # Development tools
    gh
    glab
    tea
    neovim
    gcc
    nodejs
    go
    lazygit
    just
    pre-commit
    golangci-lint
    direnv
    nix-direnv

    # Neovim runtime deps (config managed by chezmoi)
    ripgrep
    fd
    tree-sitter
    lua-language-server
    nil
    typescript-language-server
    vscode-langservers-extracted
    gopls
    rust-analyzer
    terraform-ls
    dockerfile-language-server
    yaml-language-server
    pyright
    stylua
    prettierd
    nixfmt
    statix
    deadnix
    ruff

    # Desktop applications
    alacritty
    kitty
    claude-code

    # Shell
    starship
    nushell

    # System utilities
    openssl
    htop
    btop
    unzip
    zip
    tree
    file
    which
    gnumake
    eza
    fzf
    gum
    flameshot
    television
    zellij
    bat
    zoxide
    httpie
    progress
    tldr
    trash-cli
    yazi
    remmina

    # Cloud tools
    awscli2

    # Container tools
    distrobox
    lazydocker

    # kubernetes
    k9s
    popeye
    dyff
    kubectl
    kustomize
    kubernetes-helm
    jsonnet
    kubectl-cnpg
    kind
    argocd
    kubebuilder

    terraform
    ansible
    # Network tools
    dig
    nmap
    traceroute

    # Text processing
    jq
    yq
    ripgrep
    fd

    # GTK THEMES
    tokyonight-gtk-theme
    papirus-icon-theme
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Common programs
  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      source ${pkgs.zsh-abbr}/share/zsh/zsh-abbr/zsh-abbr.plugin.zsh
    '';
  };

  programs.firefox.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "robert" ];
  };

  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      vivaldi-bin
    '';
    mode = "0755";
  };

  # Allow dynamically linked binaries (e.g. cursor-agent, VS Code extensions)
  programs.nix-ld.enable = true;

  environment.variables.EDITOR = "nvim";
  environment.variables.VISUAL = "nvim";

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
