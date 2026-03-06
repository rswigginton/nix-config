{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "Robert Wigginton";
    userEmail = "rswigginton@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;

      core = {
        editor = "nvim";
        autocrlf = "input";
      };

      credential."https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";

      merge = {
        tool = "vimdiff";
        conflictstyle = "diff3";
      };

      diff = {
        colorMoved = "default";
        tool = "vimdiff";
      };

      # Better diffs
      delta = {
        enable = true;
        options = {
          navigate = true;
          line-numbers = true;
          syntax-theme = "Dracula";
        };
      };
    };

    aliases = {
      # Shortcuts
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";

      # Useful aliases
      last = "log -1 HEAD";
      unstage = "reset HEAD --";
      amend = "commit --amend --no-edit";

      # Pretty log
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";

      # List branches sorted by last modified
      b = "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'";
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      "*~"
      ".idea"
      ".vscode"
      "node_modules"
      ".env"
    ];
  };

  # lazygit config managed by chezmoi
}
