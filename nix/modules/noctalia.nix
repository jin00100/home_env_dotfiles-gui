{ inputs, pkgs, config, lib, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = { position = "top"; height = 36; };
      launcher = { view = "grid"; };
      wallpaper = {
        enabled = true;
        overviewEnabled = true;
        automationEnabled = true;
        wallpaperChangeMode = "random";
        randomIntervalSec = 600;
        overviewBlur = 0.5;
        overviewTint = 0.5;
        useWallhaven = true;
        wallhavenQuery = "dark";
        wallhavenCategories = "111";
        wallhavenPurity = "100";
        wallhavenSorting = "random";
        transitionType = [ "fade" "pixelate" "blur" ];
        transitionDuration = 1500;
      };
      colorSchemes.predefinedScheme = "Ayu";
    };
  };
}
