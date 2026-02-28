{ pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./firefox.nix
    ./hyprland.nix
  ];
}