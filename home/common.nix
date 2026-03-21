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
    (writeShellScriptBin "nce" ''
      CONFIG_DIR="$HOME/nix-config"
      ''${EDITOR:-nvim} "$CONFIG_DIR"
      if [ -n "$(git -C "$CONFIG_DIR" status --porcelain)" ]; then
        git -C "$CONFIG_DIR" add -A
        git -C "$CONFIG_DIR" commit -m "update"
        sudo nixos-rebuild switch --flake "$CONFIG_DIR"
        if [ $? -eq 0 ]; then
          git -C "$CONFIG_DIR" push
        else
          echo "Rebuild failed — changes committed locally but not pushed."
        fi
      else
        echo "No changes detected."
      fi
    '')
    devenv
    httpie
    progress
    tldr
    trash-cli
    yazi
  ];
}
