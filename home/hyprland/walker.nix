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
      theme = "tokyo-night";

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
      tokyo-night = {
        style = ''
          /* Tokyo Night color scheme */
          @define-color selected-text #7dcfff;
          @define-color text #cfc9c2;
          @define-color base #1a1b26;
          @define-color border #33ccff;
          @define-color foreground #cfc9c2;
          @define-color background #1a1b26;

          /* Reset all elements */
          #window,
          #box,
          #search,
          #password,
          #input,
          #prompt,
          #clear,
          #typeahead,
          #list,
          child,
          scrollbar,
          slider,
          #item,
          #text,
          #label,
          #sub,
          #activationlabel {
            all: unset;
          }

          * {
            font-family: 'JetBrainsMono Nerd Font', monospace;
            font-size: 18px;
          }

          /* Window */
          #window {
            background: transparent;
            color: @text;
          }

          /* Main box container */
          #box {
            background: alpha(@base, 0.95);
            padding: 20px;
            border: 2px solid @border;
            border-radius: 0px;
          }

          /* Search container */
          #search {
            background: @base;
            padding: 10px;
            margin-bottom: 0;
          }

          /* Hide prompt icon */
          #prompt {
            opacity: 0;
            min-width: 0;
            margin: 0;
          }

          /* Hide clear button */
          #clear {
            opacity: 0;
            min-width: 0;
          }

          /* Input field */
          #input {
            background: none;
            color: @text;
            padding: 0;
          }

          #input placeholder {
            opacity: 0.5;
            color: @text;
          }

          /* Hide typeahead */
          #typeahead {
            opacity: 0;
          }

          /* List */
          #list {
            background: transparent;
          }

          /* List items */
          child {
            padding: 0px 12px;
            background: transparent;
            border-radius: 0;
          }

          child:selected,
          child:hover {
            background: transparent;
          }

          /* Item layout */
          #item {
            padding: 0;
          }

          /* Icon */
          #icon {
            margin-right: 10px;
            -gtk-icon-transform: scale(0.7);
          }

          /* Text */
          #text {
            color: @text;
            padding: 14px 0;
          }

          #label {
            font-weight: normal;
          }

          /* Selected state */
          child:selected #text,
          child:selected #label,
          child:hover #text,
          child:hover #label {
            color: @selected-text;
          }

          /* Hide sub text */
          #sub {
            opacity: 0;
            font-size: 0;
            min-height: 0;
          }

          /* Hide activation label */
          #activationlabel {
            opacity: 0;
            min-width: 0;
          }

          /* Scrollbar styling */
          scrollbar {
            opacity: 0;
          }

          /* Hide spinner */
          #spinner {
            opacity: 0;
          }

          /* Hide AI elements */
          #aiScroll,
          #aiList,
          .aiItem {
            opacity: 0;
            min-height: 0;
          }

          /* Bar entry (switcher) */
          #bar {
            opacity: 0;
            min-height: 0;
          }

          .barentry {
            opacity: 0;
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
