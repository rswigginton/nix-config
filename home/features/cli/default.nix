{pkgs, ...}: {
  imports = [
    ./fish.nix
    ./atuin.nix
    ./fzf.nix
    ./starship.nix
    ./tmux.nix
    ./git.nix
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
    # Development environments
    devenv
    
    # CLI utilities  
    httpie
    progress
    tldr
    trash-cli
    yazi
    
    # Note: The following are now in system packages:
    # - claude-code, lazygit (in hosts/mimir/configuration.nix)
    # - fd, jq, ripgrep, htop, unzip, zip (in hosts/common/default.nix)
    # - gcc, go (better at system level, in hosts/common or mimir)
  ];
}

