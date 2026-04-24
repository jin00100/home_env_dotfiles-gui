{ config, pkgs, inputs, ... }:

let
  hyprlock-themes = inputs.hyprlock-themes;
in
{
  home.file.".config/hypr/hyprlock-mocha.conf".source = "${hyprlock-themes}/mocha.conf";

  xdg.configFile."hypr/hyprlock.conf".text = ''
    source = ~/.config/hypr/hyprlock-mocha.conf

    background {
        monitor =
        path = screenshot
        blur_passes = 2
    }

    label {
        monitor =
        text = $TIME
        color = $mauve
        font_size = 90
        font_family = Maple Mono NF Bold
        position = 0, 80
        halign = center
        valign = center
    }

    input-field {
        monitor =
        size = 250, 60
        outline_thickness = 2
        dots_size = 0.2
        dots_spacing = 0.2
        dots_center = true
        outer_color = $mauve
        inner_color = $surface0
        font_color = $text
        fade_on_empty = false
        placeholder_text = <i>Input Password...</i>
        hide_input = false
        position = 0, -120
        halign = center
        valign = center
    }
  '';
}
