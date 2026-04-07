{ pkgs, ... }: {
  services.desktopManager.cosmic.enable = true;
  environment.systemPackages = with pkgs; [
    cosmic-ext-applet-minimon
    wl-clipboard
  ];
}
