{ config, lib, outputs, pkgs, ... }: {
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };

  programs.carapace = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.bat = { enable = true; };

  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    extraOptions = [ "-l" "--icons" "--git" "-a" ];
  };

  home.packages = with pkgs; [
    devenv
    httpie
    progress
    tldr
    trash-cli
    yazi
  ];
}
