{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "xterm-256color";
      };
      
      window = {
        padding = {
          x = 14;
          y = 14;
        };
        decorations = "None";
        opacity = 0.98;
      };
      
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
        };
        size = 10;
      };
      
      keyboard.bindings = [
        { key = "F11"; action = "ToggleFullscreen"; }
      ];
      
      terminal.shell = {
        program = "bash";
        args = [
          "--login"
          "-c" 
          "if [ $(pgrep -c alacritty) -le 1 ] && command -v tmux >/dev/null 2>&1; then tmux new-session -A -s Home; else $SHELL; fi"
        ];
      };
      
      # Tokyo Night color scheme
      colors = {
        primary = {
          background = "#1a1b26";
          foreground = "#c0caf5";
        };
        
        normal = {
          black = "#15161e";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#a9b1d6";
        };
        
        bright = {
          black = "#414868";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#c0caf5";
        };
        
        indexed_colors = [
          { index = 16; color = "#ff9e64"; }
          { index = 17; color = "#db4b4b"; }
        ];
      };
    };
  };
}