{ pkgs, inputs, ... }:
{
  imports = [
    inputs.walker.homeManagerModules.walker
  ];

  programs.walker = {
    enable = true;
    runAsService = true;
    config = {
      force_keyboard_focus = true;
      close_when_open = true;
      click_to_close = true;
      single_click_activation = true;
      theme = "breeze-dark";

      shell = {
        exclusive_zone = -1;
        layer = "overlay";
        anchor_top = true;
        anchor_bottom = true;
        anchor_left = true;
        anchor_right = true;
      };

      placeholders = {
        default = { input = "Search"; list = "No Results"; };
      };

      keybinds = {
        close = [ "Escape" ];
        next = [ "Down" ];
        previous = [ "Up" ];
      };

      providers = {
        default = [ "desktopapplications" "calc" "websearch" ];
        empty = [ "desktopapplications" ];
        max_results = 50;

        prefixes = [
          { prefix = "="; provider = "calc"; }
          { prefix = ">"; provider = "runner"; }
          { prefix = "/"; provider = "files"; }
          { prefix = "@"; provider = "websearch"; }
          { prefix = ":"; provider = "clipboard"; }
        ];

        actions = {
          desktopapplications = [
            { action = "start"; default = true; bind = "Return"; }
            { action = "start:keep"; label = "open+next"; bind = "shift Return"; after = "KeepOpen"; }
          ];
          calc = [
            { action = "copy"; default = true; bind = "Return"; }
          ];
          websearch = [
            { action = "search"; default = true; bind = "Return"; }
            { action = "open_url"; label = "open url"; default = true; bind = "Return"; }
          ];
          runner = [
            { action = "run"; default = true; bind = "Return"; }
            { action = "runterminal"; label = "run in terminal"; bind = "shift Return"; }
          ];
          clipboard = [
            { action = "copy"; default = true; bind = "Return"; }
            { action = "remove"; bind = "ctrl d"; after = "AsyncClearReload"; }
          ];
          files = [
            { action = "open"; default = true; bind = "Return"; }
          ];
        };
      };
    };

    themes = {
      breeze-dark = {
        style = ''
          /* Breeze Dark palette */
          @define-color window_bg_color #1b1e20;
          @define-color surface_bg_color #232629;
          @define-color overlay_bg_color #2a2e32;
          @define-color accent_bg_color  #3daee9;
          @define-color theme_fg_color   #fcfcfc;
          @define-color subtle_fg_color  #bdc3c7;
          @define-color muted_fg_color   #7f8c8d;
          @define-color cyan_color       #1abc9c;
          @define-color magenta_color    #9b59b6;
          @define-color border_color     #4d5359;
          @define-color error_bg_color   #ed1515;
          @define-color error_fg_color   #fcfcfc;

          * {
            all: unset;
            font-family: 'JetBrainsMono Nerd Font', monospace;
            font-size: 14px;
          }

          .window {
            background: transparent;
            color: @theme_fg_color;
          }

          .box-wrapper {
            background: @window_bg_color;
            padding: 16px;
            border: 2px solid @border_color;
            border-radius: 14px;
            box-shadow:
              0 19px 38px rgba(0, 0, 0, 0.45),
              0 15px 12px rgba(0, 0, 0, 0.30);
          }

          .box {
          }

          .search-container {
            background: @surface_bg_color;
            border-radius: 10px;
          }

          .input {
            background: transparent;
            caret-color: @cyan_color;
            color: @theme_fg_color;
            padding: 10px 12px;
          }

          .input placeholder {
            color: @muted_fg_color;
          }

          .input selection {
            background: @overlay_bg_color;
            color: @theme_fg_color;
          }

          .placeholder {
            color: @muted_fg_color;
            font-style: italic;
          }

          .elephant-hint {
            color: @magenta_color;
          }

          .scroll {
          }

          .list {
            color: @theme_fg_color;
          }

          .item-box {
            padding: 8px 12px;
            border-radius: 8px;
          }

          child:selected .item-box,
          row:selected .item-box {
            background: alpha(@accent_bg_color, 0.25);
          }

          .item-text-box {
          }

          .item-text {
            color: @theme_fg_color;
            font-weight: 500;
          }

          .item-subtext {
            color: @subtle_fg_color;
            font-size: 12px;
            opacity: 0.75;
          }

          child:selected .item-text {
            color: @cyan_color;
          }

          child:selected .item-subtext {
            color: @theme_fg_color;
            opacity: 0.9;
          }

          .item-quick-activation {
            background: alpha(@accent_bg_color, 0.25);
            border-radius: 5px;
            padding: 6px 10px;
            color: @cyan_color;
          }

          .calc .item-text {
            font-size: 22px;
            color: @magenta_color;
          }

          .preview {
            border: 1px solid alpha(@accent_bg_color, 0.25);
            border-radius: 10px;
            color: @theme_fg_color;
          }

          .preview-box {
            color: @theme_fg_color;
          }

          .keybinds {
            padding-top: 10px;
            border-top: 1px solid @overlay_bg_color;
            font-size: 12px;
            color: @subtle_fg_color;
          }

          .keybind-bind {
            text-transform: lowercase;
            opacity: 0.5;
          }

          .keybind-label {
            padding: 2px 4px;
            border-radius: 4px;
            border: 1px solid @muted_fg_color;
          }

          .keybind-button:hover {
            opacity: 0.85;
          }

          .error {
            padding: 10px;
            background: @error_bg_color;
            color: @error_fg_color;
            border-radius: 8px;
          }

          :not(.calc).current {
            font-style: italic;
            color: @magenta_color;
          }

          scrollbar {
            opacity: 0;
          }

          popover {
            background: @surface_bg_color;
            border: 1px solid @border_color;
            border-radius: 12px;
            padding: 8px;
            color: @theme_fg_color;
          }
        '';
      };
    };

    elephant = {
      providers = [
        "desktopapplications"
        "calc"
        "clipboard"
        "files"
        "runner"
        "websearch"
        "windows"
        "bookmarks"
        "symbols"
      ];
    };
  };
}
