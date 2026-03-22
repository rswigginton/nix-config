{ pkgs, ... }: {
  home.packages = with pkgs; [
    hyprpaper
  ];

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/.config/backgrounds/Staircase.png
    wallpaper = , ~/.config/backgrounds/Staircase.png
    splash = false
  '';
}
