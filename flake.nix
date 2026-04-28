{
  description = "Dynamic and Portable Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprlock-themes = {
      url = "github:catppuccin/hyprlock";
      flake = false;
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # This function will generate a configuration for a given username and system
      mkHomeConfig = username: system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit inputs username;
            # We no longer need to pass homeDirectory as home-manager can derive it
          };
          modules = [ ./nix/home.nix ];
        };

      # Get the current username from the environment.
      # This is impure, but it's what makes the configuration portable.
      currentUsername = builtins.getEnv "USER";

    in {
      # The primary, dynamic home configuration.
      # It dynamically generates a configuration for the CURRENT user.
      # `nix run . -- switch` or `home-manager switch` will pick this up automatically.
      homeConfigurations = nixpkgs.lib.genAttrs [ currentUsername ] (username:
        mkHomeConfig username "x86_64-linux"
      );

      # You can still keep explicit configurations for other machines if you need them
      # for cross-compilation or testing.
      # For example:
      # homeConfigurations."some-other-user" = mkHomeConfig "some-other-user" "aarch64-linux";
    };
}
