{ pkgs, ... }: {
  home.packages = with pkgs; [
    hyprlock
  ];

  xdg.configFile."hypr/hyprlock.conf".text = ''
    general {
        disable_loading_bar = true
        no_fade_in = false
    }

    background {
        monitor =
        color = rgba(26,27,38,1.0)
        path = ~/.config/backgrounds/Staircase.png
        blur_passes = 2
    }

    animations {
        enabled = false
    }

    input-field {
        monitor =
        size = 200, 50
        outline_thickness = 3
        dots_size = 0.33
        dots_spacing = 0.15
        dots_center = true
        dots_rounding = -1
        outer_color = rgb(7aa2f7)
        inner_color = rgba(26,27,38,0.1)
        font_color = rgba(205,214,244,1.0)
        fade_on_empty = true
        fade_timeout = 1000
        placeholder_text = <i>Input Password...</i>
        hide_input = false
        rounding = -1
        check_color = rgb(204, 136, 34)
        fail_color = rgb(204, 34, 34)
        fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
        fail_transition = 300
        capslock_color = -1
        numlock_color = -1
        bothlock_color = -1
        invert_numlock = false
        swap_font_color = false
        position = 0, -20
        halign = center
        valign = center
    }
  '';
}
