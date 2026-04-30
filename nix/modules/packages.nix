{ config, pkgs, lib, ... }:

{
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];

  home.packages = with pkgs; [
    # [시스템 유틸 및 CLI 도구]
    # 순수하게 도구로서 작동하며 시스템 라이브러리와 충돌이 적은 것들 위주
    neofetch 
    btop          # Modern system monitor
    ripgrep 
    fd 
    unzip 
    lazygit 
    lolcat
    lsb-release
    xclip 
    xsel 
    wl-clipboard
    ncdu
    duf
    tldr
    jq            # JSON processor
    yq-go         # YAML processor (yq)
    
    # [Neovim 보조 도구 (LSP/Parsers)]
    # 에디터 경험을 위해 가벼운 서버들만 유지
    tree-sitter   # Tree-sitter CLI (Fix checkhealth error)
    nil           # Nix Language Server
    ast-grep      # ast-grep CLI
    lua51Packages.jsregexp # Luasnip dependency
    gopls         # Go LSP
    clang-tools   # clangd 등 (헤더 검색 등 에디터용)
    yaml-language-server              # YAML LSP
    nodePackages.bash-language-server # Bash LSP
    dockerfile-language-server-nodejs # Dockerfile LSP

    # 폰트
    maple-mono.NF
    nerd-fonts.ubuntu-mono 
    monaspace
    nerd-fonts.jetbrains-mono
    fnm

    # --- GUI & Desktop Essentials ---
    swaybg
    hyprpaper
    networkmanagerapplet
    grim
    slurp
    swappy
    ayu-theme-gtk
    catppuccin-kvantum
    papirus-icon-theme
    bibata-cursors
    libnotify
    pamixer
    brightnessctl
    pavucontrol
    gitui
    foot # Fallback terminal for VM testing without OpenGL
  ];
}
