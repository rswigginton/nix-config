{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hostname
  networking.hostName = "tyr";

  # Enable networking
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

  # Define user account
  users.users.robert = {
    isNormalUser = true;
    description = "Robert";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  # Enable COSMIC Desktop Environment
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # Host-specific packages (common packages are in hosts/common/default.nix)
  environment.systemPackages = with pkgs; [
    # Desktop applications
    alacritty
    opencode
    claude-code
    
    # Development
    nodejs
    go
    lazygit
  ];

  # Programs
  programs.firefox.enable = true;
  
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "robert" ];
  };

  # System state version
  system.stateVersion = "25.11";
}
