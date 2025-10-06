{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    baseIndex = 1;
    historyLimit = 1000000;
    mouse = true;
    keyMode = "vi";
    escapeTime = 0;
    prefix = "C-Space";
    
    extraConfig = ''
      # Terminal settings
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -g default-terminal "''${TERM}"
      
      # General settings
      set -g detach-on-destroy off
      set -g renumber-windows on
      set -g set-clipboard on
      set -g status-interval 3
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM
      
      # Status bar
      set -g status-position top
      set -g status-style 'bg=default'
      set -g status-left "#[fg=blue,bold]#S "
      set -g status-right " #[fg=white,nobold]#(gitmux -cfg $HOME/.config/tmux/gitmux.yml)"
      set -g status-left-length 200
      set -g status-right-length 200
      
      # Window status
      set -g window-status-current-format '*#[fg=magenta]#W'
      set -g window-status-format ' #[fg=gray]#W'
      
      # Message and mode styles
      set -g message-command-style bg=default,fg=yellow
      set -g message-style bg=default,fg=yellow
      set -g mode-style bg=default,fg=yellow
      
      # Pane borders
      set -g pane-active-border-style "bg=default,fg=#f4a261"
      set -g pane-border-style "bg=default,fg=colour245"
      set -g pane-border-lines "double"
      
      # Key bindings
      unbind C-b
      bind-key C-Space send-prefix
      
      # Split panes
      unbind %
      bind | split-window -h
      unbind '"'
      bind - split-window -v
      
      # Synchronize panes
      bind e set-window-option synchronize-panes
      
      # Reload config
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf
      
      # Resize panes
      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r h resize-pane -L 5
      bind -r m resize-pane -Z
      
      # Copy mode
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection
      unbind -T copy-mode-vi MouseDragEnd1Pane
      
      # Kill pane without confirmation
      bind-key x kill-pane
      
      # Session management popups
      bind-key "K" display-popup -E -w 60% "sesh connect \"$(
        sesh list -ictd | gum filter --limit 1 --fuzzy --no-sort --placeholder 'Pick a sesh' --prompt='⚡'
      )\""
      
      bind-key "g" new-window "glow"
      bind-key "R" display-popup -E -w 40% "gwt"
      bind-key "T" display-popup -E -w 40% "tmux_sessions"
      bind-key "D" display-popup -E -w 80% -h 80% "lazydocker"
      
      # Toggle terminal
      bind-key -n 'M-t' run-shell "''${HOME}/.config/bin/toggle-term"
      
      # Vim-tmux navigator (manual configuration)
      # Smart pane switching with awareness of Vim splits
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"
      
      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
    '';
  };
}