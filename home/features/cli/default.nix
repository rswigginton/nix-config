{pkgs, ...}: {
  imports = [
    ./fish.nix
    ./atuin.nix
    ./fzf.nix
    ./starship.nix
  ];

  programs.carapace = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
  };

  programs.bat = {enable = true;};

  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
    nix-direnv.enable =
      true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    extraOptions = ["-l" "--icons" "--git" "-a"];
  };

  home.packages = with pkgs; [
    claude-code
    coreutils
    devenv
    fd
    gcc
    go
    htop
    httpie
    jq
    lazygit
    progress
    ripgrep
    tldr
    trash-cli
    unzip
    yazi
    zip
  ];
}

