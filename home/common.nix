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
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
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
    enableZshIntegration = true;
    extraOptions = [ "-l" "--icons" "--git" "-a" ];
  };

  home.packages = with pkgs; [
    (writeShellScriptBin "nce" ''
      CONFIG_DIR="$HOME/nix-config"
      cd "$CONFIG_DIR" && ''${EDITOR:-nvim} .
      if [ -n "$(git -C "$CONFIG_DIR" status --porcelain)" ]; then
        git -C "$CONFIG_DIR" add -A
        MSG=$(git -C "$CONFIG_DIR" diff --cached --name-only | sed 's|.*/||; s|\.nix$||' | sort -u | paste -sd ', ')
        git -C "$CONFIG_DIR" commit -m "update $MSG"
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
