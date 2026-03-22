{ pkgs, ... }: {
  home.packages = with pkgs; [
    waybar
  ];

  xdg.configFile."waybar/config.jsonc".text = builtins.toJSON {
    reload_style_on_change = true;
    layer = "top";
    position = "top";
    spacing = 0;
    height = 27;
    modules-left = [
      "hyprland/workspaces"
    ];
    modules-center = [];
    modules-right = [
      "tray"
      "bluetooth"
      "network"
      "pulseaudio"
      "cpu#icon"
      "cpu#text"
      "memory#icon"
      "memory#text"
      "battery"
      "clock"
      "custom/notification"
    ];
    "hyprland/workspaces" = {
      on-click = "activate";
      format = "{icon}";
      format-icons = {
        default = "";
        "1" = "1";
        "2" = "2";
        "3" = "3";
        "4" = "4";
        "5" = "5";
        "6" = "6";
        "7" = "7";
        "8" = "8";
        "9" = "9";
        active = "󱓻";
      };
      persistent-workspaces = {
        "1" = [];
        "2" = [];
        "3" = [];
        "4" = [];
        "5" = [];
      };
    };
    tray = {
      spacing = 14;
      icon-size = 15;
    };
    "cpu#icon" = {
      format = "󰍛";
      tooltip = false;
    };
    "cpu#text" = {
      interval = 1;
      format = "{usage}%";
      signal = 1;
      on-click = "alacritty -e btop";
      tooltip = true;
      tooltip-format = "CPU Usage: {usage}%";
    };
    "memory#icon" = {
      interval = 3;
      format = "";
      tooltip = false;
    };
    "memory#text" = {
      interval = 3;
      format = "{percentage}%";
      signal = 2;
      tooltip = true;
      tooltip-format = "RAM: {used:0.1f}GB / {total:0.1f}GB";
    };
    clock = {
      format = "{:%a, %d %b %I:%M %p}";
      format-alt = "{:%d %B W%V %Y}";
      tooltip = false;
    };
    network = {
      format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
      format = "{icon}";
      format-wifi = "{icon}";
      format-ethernet = "󰀂";
      format-disconnected = "󰖪";
      tooltip-format-wifi = "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
      tooltip-format-ethernet = "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
      tooltip-format-disconnected = "Disconnected";
      interval = 3;
      spacing = 1;
    };
    battery = {
      format = "{capacity}% {icon}";
      format-discharging = "{icon}";
      format-charging = "{icon}";
      format-plugged = "";
      format-icons = {
        charging = [ "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅" ];
        default = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
      };
      format-full = "󰂅";
      tooltip-format-discharging = "{power:>1.0f}W↓ {capacity}%";
      tooltip-format-charging = "{power:>1.0f}W↑ {capacity}%";
      interval = 5;
      states = {
        warning = 20;
        critical = 10;
      };
    };
    bluetooth = {
      format = "";
      format-disabled = "󰂲";
      format-connected = "";
      tooltip-format = "Devices connected: {num_connections}";
      on-click = "blueberry";
    };
    pulseaudio = {
      format = "{icon}";
      on-click-right = "pamixer -t";
      tooltip-format = "Playing at {volume}%";
      scroll-step = 5;
      format-muted = "󰝟";
      format-icons = {
        default = [ "" "" "" ];
      };
    };
    "custom/notification" = {
      tooltip = false;
      format = "{icon}";
      format-icons = {
        notification = "󰂚";
        none = "󰂜";
        dnd-notification = "󰂛";
        dnd-none = "󰪑";
      };
      return-type = "json";
      exec = "swaync-client -swb";
      on-click = "swaync-client -t -sw";
      on-click-right = "swaync-client -d -sw";
      escape = true;
    };
  };

  xdg.configFile."waybar/style.css".text = ''
    * {
      background-color: #1a1b26;
      color: #c0caf5;

      border: none;
      border-radius: 0;
      min-height: 0;
      font-family: 'JetBrainsMono Nerd Font';
      font-size: 14px;
    }

    .modules-left {
      margin-left: 8px;
    }

    .modules-right {
      margin-right: 8px;
    }

    #workspaces button {
      all: initial;
      color: #c0caf5;
      padding: 0 6px;
      margin: 0 1.5px;
      min-width: 9px;
    }

    #workspaces button.empty {
      opacity: 0.5;
    }

    #workspaces button.active {
      color: #7aa2f7;
    }

    #tray,
    #cpu.icon,
    #cpu.text,
    #memory.icon,
    #memory.text,
    #battery,
    #network,
    #bluetooth,
    #pulseaudio,
    #custom-notification {
      min-width: 12px;
      margin: 0 7.5px;
    }

    tooltip {
      padding: 2px;
    }

    #clock {
      margin-left: 8.75px;
    }

    .hidden {
      opacity: 0;
    }
  '';
}
