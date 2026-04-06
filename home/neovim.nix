{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;

    extraPackages = with pkgs; [
      # LazyVim dependencies
      lazygit
      ripgrep
      fd

      # LSP servers
      lua-language-server
      nil # Nix LSP
      typescript-language-server
      vscode-langservers-extracted # HTML/CSS/JSON/ESLint
      gopls
      rust-analyzer
      terraform-ls
      dockerfile-language-server
      yaml-language-server
      pyright

      # Formatters / Linters
      stylua
      prettierd
      nixfmt
      ruff

      # Additional tools
      tree-sitter
      gcc # needed for treesitter compilation
    ];
  };

  # Lua config is managed by chezmoi, not Nix
  # Nix only provides neovim + extraPackages (LSPs, formatters, etc.)
}
