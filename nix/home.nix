{ config, pkgs, username, ... }:

{
  # [User Info - Dynamically passing from flake.nix]
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11"; 

  # [Module Loader] Load feature-specific files
  imports = [
    ./modules/shell.nix
    ./modules/packages.nix
    ./modules/neovim.nix
    ./modules/zellij.nix
    ./modules/git.nix
    ./modules/ghostty.nix
    
    # --- New GUI & Desktop Environment ---
    ./modules/hyprland.nix
    ./modules/hyprlock.nix
    ./modules/hypridle.nix
    ./modules/theme.nix
    ./modules/noctalia.nix
    ./modules/swappy.nix

    # --- New Shells ---
    ./modules/bash.nix
    ./modules/nushell.nix
  ];

  # [Fix] Create empty config files to prevent Hyprland from crashing on first start
  home.file = {
    ".config/hypr/monitors.conf".text = "";
    ".config/hypr/workspaces.conf".text = "";
  };

  targets.genericLinux.enable = true;
  fonts.fontconfig.enable = true;

  # [Auto GC] Automatically clean up unused Nix histories weekly
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  programs.home-manager.enable = true;
}
