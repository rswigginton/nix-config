{ ... }: {
  imports = [
    ./home.nix
    ../common
    ../features/cli/common.nix
    ../features/cli/fish.nix
    ../features/cli/atuin.nix
    ../features/cli/fzf.nix
    ../features/cli/starship.nix
    ../features/cli/tmux.nix
    ../features/cli/git.nix
    ../features/desktop
  ];
}
