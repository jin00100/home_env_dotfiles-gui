{ config, pkgs, ... }:

{
  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
        lock_cmd = pidof hyprlock || /usr/bin/hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
    }

    listener {
        timeout = 540                                
        on-timeout = /usr/bin/brightnessctl set 10%
        on-resume = /usr/bin/brightnessctl set 100%
    }

    listener {
        timeout = 600                                
        on-timeout = loginctl lock-session
    }

    listener {
        timeout = 900                                
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
    }
  '';
}
