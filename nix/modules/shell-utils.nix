{ config, pkgs, lib, ... }:

{
  home.file.".config/starship-ssh.toml".source = ./starship-ssh.toml;

  # 1. Starship Prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.importTOML ./starship.toml;
  };

  # 2. Eza (ls alternative)
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  # 3. Zoxide (cd alternative)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  # 4. Bat (cat alternative - Syntax Highlight)
  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
  };

  # 5. FZF (Fuzzy Finder)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # 6. Direnv
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # 7. Pyenv
  programs.pyenv = {
    enable = true;
    enableZshIntegration = true;
  };

  # 8. Yazi (Terminal File Manager)
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    shellWrapperName = "y";
  };

  # Yazi 설정을 raw text로 직접 관리
  xdg.configFile."yazi/yazi.toml".text = ''
    [manager]
    show_hidden = false
    sort_by     = "alphabetical"
    linemode    = "githead"

    [status]
    left  = [
      { name = "hovered", collect = false },
      { name = "count",   collect = false },
      { name = "githead", collect = false },
    ]
    right = [
      { name = "cursor",      collect = false },
      { name = "sort",        collect = false },
      { name = "permissions", collect = false },
    ]

    [opener]
    edit = [
      { run = '${pkgs.neovim}/bin/nvim "$@"', block = true },
    ]

    [theme]
    flavor = "ayu-dark"
  '';

  xdg.configFile."yazi/init.lua".text = ''
    require("githead"):setup()
  '';

  # githead.yazi 플러그인 설치
  xdg.configFile."yazi/plugins/githead.yazi".source = pkgs.fetchFromGitHub {
    owner = "llanosrocas";
    repo = "githead.yazi";
    rev = "main";
    sha256 = "sha256-o2EnQYOxp5bWn0eLn0sCUXcbtu6tbO9pdUdoquFCTVw=";
  };

  # 9. Atuin (Magical Shell History)
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    flags = [ "--disable-up-arrow" ];
  };
}
