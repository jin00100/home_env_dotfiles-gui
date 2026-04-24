{
  description = "Dynamic Home Manager configuration";

  inputs = {
    # Nixpkgs (Unstable - latest packages)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager (Master - tracks nixpkgs)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Catppuccin Hyprlock Themes
    hyprlock-themes = {
      url = "github:catppuccin/hyprlock";
      flake = false;
    };

    # Noctalia Shell (Bar + Launcher + Shell)
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprlock-themes, noctalia, ... }@inputs:
    let
      # Use --impure flag to interpret system environment at runtime
      system = builtins.currentSystem;
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Dynamically extract Username and Home Directory
      userEnv = builtins.getEnv "USER";
      username = if userEnv != "" then userEnv else builtins.getEnv "LOGNAME";
      homeDirectory = builtins.getEnv "HOME";
      
      # Helper function to generate configurations for different architectures (if needed without --impure)
      mkConfig = sys: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${sys};
        extraSpecialArgs = { inherit inputs username homeDirectory; };
        modules = [ ./nix/home.nix ];
      };
    in {
      homeConfigurations = {
        # Default: Impure dynamic configuration (Your current powerful setup)
        "default" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs username homeDirectory; };
          modules = [ ./nix/home.nix ];
        };
        
        # Explicit Architectures (Like the other repo, for cross-compilation or strict usage)
        "jin-x86-linux"   = mkConfig "x86_64-linux";
        "jin-aarch-linux" = mkConfig "aarch64-linux";
        "jin-aarch-mac"   = mkConfig "aarch64-darwin";
      };
    };
}
