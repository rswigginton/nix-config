# Desktop / workstation bits — GUI apps, dev toolchains, fonts, login manager.
# Headless servers should NOT import this; they get just ./default.nix.

{
  lib,
  pkgs,
  ...
}:
{
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Display manager (TTY-based)
  services.displayManager.ly.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

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

  # Use neovim where the base sets vim
  environment.variables.EDITOR = lib.mkForce "nvim";
  environment.variables.VISUAL = lib.mkForce "nvim";

  environment.systemPackages = with pkgs; [
    # Dotfiles / shell history
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

    # System utilities (desktop-only convenience)
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
    freerdp

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

    # GTK THEMES
    tokyonight-gtk-theme
    papirus-icon-theme
  ];
}
