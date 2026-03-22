{ pkgs, ... }: {
  home.packages = with pkgs; [
    pyprland
  ];

  xdg.configFile."hypr/pyprland.toml".text = ''
    [pyprland]
    plugins = [
      "scratchpads",
    ]

    [scratchpads.file]
    animation = "fromTop"
    command = "kitty --class yazi -e ranger ~/"
    class = "yazi"
    size = "75% 60%"
  '';
}
