{ pkgs, ... }: {
  programs.hyprland.enable = true;

  # Use Hyprland's portal without conflicting with other DEs
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}
