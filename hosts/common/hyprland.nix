{ pkgs, ... }:
{
  programs.hyprland.enable = true;

  # Use Hyprland's portal without conflicting with other DEs
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    wl-clip-persist
    brightnessctl
    playerctl
    hyprshot
    solaar
    jq
    nautilus
    awww
    hypridle
    hyprlock
    waybar
    pwvucontrol
    swaynotificationcenter
    rofi
    rofi-calc
    rofi-emoji
    rofi-file-browser
    satty
    libnotify
  ];
}
