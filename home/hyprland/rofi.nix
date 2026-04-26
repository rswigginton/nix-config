{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "${pkgs.kitty}/bin/kitty";
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
      rofi-file-browser
    ];

    extraConfig = {
      modi = "drun,run,window,filebrowser,calc,emoji";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      font = "JetBrainsMono Nerd Font 12";
      display-drun = " Apps";
      display-run = " Run";
      display-window = " Windows";
      display-filebrowser = " Files";
      display-calc = " Calc";
      display-emoji = "󰞅 Emoji";
      drun-display-format = "{name}";
      sidebar-mode = true;
      hover-select = true;
      me-select-entry = "";
      me-accept-entry = "MousePrimary";
      kb-cancel = "Escape";
      kb-row-up = "Up,Control+k";
      kb-row-down = "Down,Control+j";
      kb-remove-to-eol = "";
      kb-accept-entry = "Return,KP_Enter";
      matching = "fuzzy";
      sort = true;
      sorting-method = "fzf";
    };

    theme = "tokyo-night";
  };

  xdg.configFile."rofi/themes/tokyo-night.rasi".text = ''
    * {
      bg:           #1a1b26;
      bg-alt:       #15161e;
      bg-overlay:   #283457;
      accent:       #7aa2f7;
      accent-soft:  rgba(122, 162, 247, 0.25);
      fg:           #c0caf5;
      fg-alt:       #a9b1d6;
      muted:        #565f89;
      cyan:         #7dcfff;
      magenta:      #bb9af7;
      border:       #7aa2f7;
      urgent:       #f7768e;

      background-color: transparent;
      text-color:       @fg;
      font:             "JetBrainsMono Nerd Font 12";
    }

    window {
      transparency:  "real";
      location:      center;
      anchor:        center;
      width:         650px;
      border-radius: 14px;
      border:        2px;
      border-color:  @border;
      background-color: @bg;
      cursor:        "default";
    }

    mainbox {
      enabled:  true;
      spacing:  12px;
      padding:  16px;
      background-color: transparent;
      children: [ inputbar, message, mode-switcher, listview ];
    }

    inputbar {
      enabled:  true;
      spacing:  8px;
      padding:  8px 12px;
      border-radius: 10px;
      background-color: @bg-alt;
      text-color:       @fg;
      children: [ prompt, entry ];
    }

    prompt {
      background-color: transparent;
      text-color:       @magenta;
    }

    entry {
      background-color: transparent;
      text-color:       @fg;
      cursor:           "text";
      placeholder:      "Search";
      placeholder-color: @muted;
    }

    mode-switcher {
      spacing:          8px;
      background-color: transparent;
    }

    button {
      padding:          6px 10px;
      border-radius:    8px;
      background-color: @bg-alt;
      text-color:       @fg-alt;
      cursor:           pointer;
    }

    button selected {
      background-color: @bg-overlay;
      text-color:       @cyan;
    }

    listview {
      enabled:  true;
      columns:  1;
      lines:    10;
      cycle:    true;
      dynamic:  true;
      scrollbar: false;
      spacing:  4px;
      background-color: transparent;
      cursor:   "default";
    }

    element {
      spacing:          10px;
      padding:          8px 12px;
      border-radius:    8px;
      background-color: transparent;
      text-color:       @fg;
      cursor:           pointer;
    }

    element selected.normal {
      background-color: @accent-soft;
      text-color:       @cyan;
    }

    element-icon {
      size:             1.2em;
      background-color: transparent;
      text-color:       inherit;
    }

    element-text {
      background-color: transparent;
      text-color:       inherit;
      highlight:        bold #7dcfff;
      vertical-align:   0.5;
      horizontal-align: 0.0;
    }

    message {
      background-color: transparent;
      padding:          0;
    }

    textbox {
      padding:          8px 12px;
      border-radius:    8px;
      background-color: @bg-alt;
      text-color:       @fg;
    }

    error-message {
      padding:          10px;
      border-radius:    8px;
      background-color: @urgent;
      text-color:       @fg;
    }
  '';

  xdg.configFile."rofi/themes/dmenu.rasi".text = ''
    * {
      bg:     #1a1b26;
      bg-alt: #15161e;
      accent: #7aa2f7;
      fg:     #c0caf5;
      cyan:   #7dcfff;
      border: #7aa2f7;
      background-color: transparent;
      text-color:       @fg;
      font: "JetBrainsMono Nerd Font 12";
    }

    window {
      location:      center;
      anchor:        center;
      width:         320px;
      border-radius: 14px;
      border:        2px;
      border-color:  @border;
      background-color: @bg;
    }

    mainbox {
      padding:  12px;
      spacing:  8px;
      children: [ listview ];
      background-color: transparent;
    }

    listview {
      lines:    5;
      columns:  1;
      cycle:    true;
      scrollbar: false;
      spacing:  4px;
      background-color: transparent;
    }

    element {
      padding:          8px 12px;
      border-radius:    8px;
      background-color: transparent;
      text-color:       @fg;
      cursor:           pointer;
    }

    element selected.normal {
      background-color: rgba(122, 162, 247, 0.25);
      text-color:       @cyan;
    }

    element-text {
      background-color: transparent;
      text-color:       inherit;
      vertical-align:   0.5;
    }
  '';
}
