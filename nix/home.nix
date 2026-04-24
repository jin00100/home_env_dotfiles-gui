{ config, pkgs, username, homeDirectory, ... }:

{
  # [User Info - Dynamically passing from flake.nix]
  home.username = username;
  home.homeDirectory = homeDirectory;
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

  targets.genericLinux.enable = true;
  fonts.fontconfig.enable = true;

  # [Auto GC] Automatically clean up unused Nix histories weekly
  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "--delete-older-than 7d";
  };

  programs.home-manager.enable = true;
}
