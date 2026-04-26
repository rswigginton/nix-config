{ pkgs, ... }:
let
  smart_focus = pkgs.writeShellScript "smart_focus.sh" ''
    direction=$1
    workspace_change=$2
    action=''${3:-focus}

    current_window=$(hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.address')

    if [ "$current_window" = "null" ] || [ -z "$current_window" ]; then
      hyprctl dispatch workspace $workspace_change
      exit 0
    fi

    if [ "$action" = "move" ]; then
      hyprctl dispatch movefocus $direction
      sleep 0.05
      new_window=$(hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.address')

      if [ "$current_window" != "$new_window" ]; then
        hyprctl dispatch focuswindow address:$current_window
        sleep 0.05
        hyprctl dispatch movewindow $direction
      else
        hyprctl dispatch movetoworkspace $workspace_change
      fi
    else
      hyprctl dispatch movefocus $direction
      sleep 0.05
      new_window=$(hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.address')

      if [ "$current_window" = "$new_window" ]; then
        hyprctl dispatch workspace $workspace_change
      fi
    fi
  '';
in
{
  home.packages = with pkgs; [
    wl-clipboard
    brightnessctl
    playerctl
    hyprshot
    solaar
    jq
    nautilus
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$terminal" = "alacritty";
      "$fileManager" = "nautilus";
      "$mainMod" = "ALT";

      monitor = [ ",preferred,auto,auto" ];

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "HYPRCURSOR_THEME,rose-pine-hyprcursor"
        "GTK_THEME,Tokyonight-Dark"
        "ICON_THEME,Papirus-Dark"

        "GDK_BACKEND,wayland,x11,*"
        "QT_QPA_PLATFORM,wayland;xcb"
        "SDL_VIDEODRIVER,wayland,x11"
        "MOZ_ENABLE_WAYLAND,1"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"
      ];

      xwayland = {
        force_zero_scaling = true;
      };

      ecosystem = {
        no_update_news = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(7aa2f7ee) rgba(bb9af7ee) 45deg";
        "col.inactive_border" = "rgba(414868aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
        no_focus_fallback = true;
      };

      decoration = {
        rounding = 5;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      group = {
        "col.border_active" = "rgba(7aa2f7ee) rgba(bb9af7ee) 45deg";
        "col.border_inactive" = "rgba(414868aa)";
        groupbar = {
          "col.inactive" = "rgba(414868aa)";
          "col.active" = "rgba(7aa2f7ee) rgba(bb9af7ee) 45deg";
          stacked = false;
          render_titles = false;
          rounding = 5;
          gradient_rounding = 5;
          round_only_edges = false;
          gradient_round_only_edges = false;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = false;
        };
      };

      bind = [
        # Applications
        "$mainMod, return, exec, $terminal"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, space, exec, rofi -show drun"
        "$mainMod, P, pseudo,"
        "$mainMod, period, togglesplit,"
        "$mainMod, N, exec, swaync-client -t -sw"

        # Power menu
        "$mainMod, escape, exec, ~/.config/bin/rofi_menu_power"

        # Screenshots
        "$mainMod, PRINT, exec, hyprshot -m region"
        "CTRL SHIFT, 4, exec, hyprshot -m region --clipboard-only"

        # Move focus (smart focus for up/down)
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, exec, ${smart_focus} u -1"
        "$mainMod, j, exec, ${smart_focus} d +1"

        # Move windows (smart move for up/down)
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, l, movewindow, r"
        "$mainMod SHIFT, k, exec, ${smart_focus} u -1 move"
        "$mainMod SHIFT, j, exec, ${smart_focus} d +1 move"

        # Window groups
        "$mainMod, G, togglegroup"
        "$mainMod, tab, changegroupactive, f"
        "$mainMod SHIFT, tab, changegroupactive, b"

        # Workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Scratchpad
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Scroll workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$mainMod, down, workspace, e+1"
        "$mainMod, up, workspace, e-1"
      ];

      # Media keys
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];

      bindl = [
        ",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPause, exec, playerctl play-pause"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioPrev, exec, playerctl previous"
      ];

      # Mouse binds
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Window rules
      # windowrulev2 = [
      #   "suppressevent maximize, class:.*"
      #   "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      # ];

      # Autostart
      exec-once = [
        "waybar"
        "swaync"
        "hypridle"
        "hyprpaper"
        "solaar --window=hide"
        # "pypr"
      ];
    };
  };

}
