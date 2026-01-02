{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.neovim;
in {
  options.features.cli.neovim.enable = mkEnableOption "enable neovim with LazyVim";

  config = mkIf cfg.enable {
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
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted # HTML/CSS/JSON/ESLint
        gopls
        rust-analyzer
        terraform-ls
        dockerfile-language-server-nodejs
        yaml-language-server
        pyright

        # Formatters
        stylua
        prettierd
        nixfmt-rfc-style

        # Additional tools
        tree-sitter
        gcc # needed for treesitter compilation
      ];
    };

    # Ensure XDG directories exist
    xdg.enable = true;

    # Neovim configuration files
    xdg.configFile = {
      "nvim/init.lua".text = ''
        -- bootstrap lazy.nvim, LazyVim and your plugins
        require("config.lazy")
      '';

      "nvim/stylua.toml".source = ./nvim/stylua.toml;
      "nvim/lazyvim.json".source = ./nvim/lazyvim.json;
      "nvim/.neoconf.json".source = ./nvim/neoconf.json;

      # Config files
      "nvim/lua/config/lazy.lua".source = ./nvim/lua/config/lazy.lua;
      "nvim/lua/config/options.lua".source = ./nvim/lua/config/options.lua;
      "nvim/lua/config/keymaps.lua".source = ./nvim/lua/config/keymaps.lua;
      "nvim/lua/config/autocmds.lua".source = ./nvim/lua/config/autocmds.lua;

      # Plugin files
      "nvim/lua/plugins/colorscheme.lua".source = ./nvim/lua/plugins/colorscheme.lua;
      "nvim/lua/plugins/disabled.lua".source = ./nvim/lua/plugins/disabled.lua;
      "nvim/lua/plugins/navigator.lua".source = ./nvim/lua/plugins/navigator.lua;
      "nvim/lua/plugins/octo.lua".source = ./nvim/lua/plugins/octo.lua;
      "nvim/lua/plugins/sidekick.lua".source = ./nvim/lua/plugins/sidekick.lua;
      "nvim/lua/plugins/snacks.lua".source = ./nvim/lua/plugins/snacks.lua;
      "nvim/lua/plugins/treesitter.lua".source = ./nvim/lua/plugins/treesitter.lua;
      "nvim/lua/plugins/ts-comments.lua".source = ./nvim/lua/plugins/ts-comments.lua;
      "nvim/lua/plugins/vimwiki.lua".source = ./nvim/lua/plugins/vimwiki.lua;
      "nvim/lua/plugins/yaml.lua".source = ./nvim/lua/plugins/yaml.lua;
    };
  };
}
