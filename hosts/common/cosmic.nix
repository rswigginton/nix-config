{ pkgs, ... }: {
  services.desktopManager.cosmic.enable = true;
  environment.systemPackages = [ pkgs.cosmic-ext-applet-minimon ];
}
