{ pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./firefox.nix
    # Add other desktop app configs here as needed
  ];
}