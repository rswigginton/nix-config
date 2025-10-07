# Common configuration for all hosts

{ lib, inputs, outputs, pkgs, ... }: {
  imports = 
    [
      inputs.home-manager.nixosModules.home-manager
      ./fish.nix
    ];

  # Home-manager common settings
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs; };
    backupFileExtension = "backup";  # Automatically backup conflicting files
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # Common system packages for all hosts
  environment.systemPackages = with pkgs; [
    # Essential tools
    vim
    wget
    git
    curl
    
    # Development tools
    gh
    neovim
    gcc
    
    # System utilities
    htop
    btop
    unzip
    zip
    tree
    file
    which
    gnumake
    eza
    
    # Network tools
    dig
    nmap
    traceroute
    
    # Text processing
    jq
    ripgrep
    fd
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Common programs configuration
  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        "robert"
      ]; # Set users that are allowed to use the flake command
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    registry = (lib.mapAttrs (_: flake: { inherit flake; }))
      ((lib.filterAttrs (_: lib.isType "flake")) inputs);
    nixPath = [ "/etc/nix/path" ];
  };
}
