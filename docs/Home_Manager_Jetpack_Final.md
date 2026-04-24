# Nix Home Manager Ultimate Setup (Jetpack Edition)

## 1. 개요

이 문서는 Nix Home Manager를 사용하여 리눅스 개발 환경을 구축하는 최종 가이드이다.
Native Linux(Ubuntu 등)와 WSL 환경을 하나의 통합된 코드베이스로 관리하며, Starship(Jetpack) 테마와 Zellij/Neovim 생산성 도구가 완벽하게 통합되어 있다.

**주요 기능:**
- **Core:** Nix Flakes + Home Manager (Multi-architecture Support)
- **Shell:** Zsh + Starship (SSH Auto-detect) + Eza + Zoxide (cd) + Bat + btop + FZF + **Direnv** + **fnm (Node Version Manager)**
- **Editor:** Neovim (Tokyonight, OSC 52 Clipboard, Beautiful Diagnostics, Snippets, LSP: YAML/Bash/Docker/Go/C++)
- **Terminal:** Zellij (Modern Rust-based Terminal Workspace, Prefix Ctrl+g, Cyber-blue Theme)
- **Auto-Install:** Gemini CLI, Tree-sitter CLI, jq, yq (via Nix)
- **Dev Tools:** gcc, clang, make, cmake, go, gopls

## 2. 필수 사전 준비 (Manual Steps)

### 2.1 Ghostty 터미널 설치 (수동)
Ghostty는 최신 터미널 에뮬레이터로, 아직 패키지 매니저에 안정적으로 포함되지 않은 경우가 많아 직접 설치를 권장한다.

1.  **다운로드:** [Ghostty 공식 웹사이트](https://ghostty.org/download) 또는 GitHub Release 페이지에서 자신의 OS에 맞는 버전을 다운로드한다.
2.  **설치 (Ubuntu/Debian 예시):**
    ```bash
    # 다운로드 받은 .deb 파일이 있는 경로로 이동
    sudo dpkg -i ghostty_*.deb
    sudo apt-get install -f # 의존성 문제 발생 시 해결
    ```
3.  **설정 파일:**
    Home Manager가 `~/.config/ghostty/config` 파일을 자동으로 생성 관리하므로, 별도의 설정 파일을 수동으로 만들 필요는 없다. (설정 내용은 `nix/home.nix` 참조)

### 2.2 Nix 설치 (Multi-user)
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### 2.3 Experimental Features 활성화
Flakes 기능을 사용하기 위해 필수적이다.
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

## 3. 디렉토리 구조

설정 파일은 기능별로 모듈화되어 `nix/modules` 내부에 위치한다.

```text
~/home_env_dotfiles
├── flake.nix             # [Entry] 통합 설정 엔트리
├── nix
│   ├── home.nix          # [Main] 모듈 로더 및 기본 설정
│   └── modules
│       ├── git.nix       # Git 사용자 설정
│       ├── neovim.nix    # Neovim 플러그인 및 설정
│       ├── packages.nix  # 시스템 패키지 & 설치 스크립트
│       ├── shell.nix     # Zsh, Starship, Alias, Zellij 실행 로직, Direnv
│       ├── starship.toml # Starship 테마 설정 (Jetpack)
│       └── zellij.nix     # Zellij 옵션 및 키바인딩
└── .gitignore
```

## 4. 파일별 상세 코드

### 4.1 ~/home_env_dotfiles/flake.nix
`--impure`를 활용한 동적 설정과 더불어, 다중 아키텍처(ARM, Mac 등)에 대한 명시적 지원도 포함되어 있습니다.

```nix
{
  description = "Dynamic Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = builtins.currentSystem;
      pkgs = nixpkgs.legacyPackages.${system};
      userEnv = builtins.getEnv "USER";
      username = if userEnv != "" then userEnv else builtins.getEnv "LOGNAME";
      homeDirectory = builtins.getEnv "HOME";
      
      mkConfig = sys: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${sys};
        extraSpecialArgs = { inherit username homeDirectory; };
        modules = [ ./nix/home.nix ];
      };
    in {
      homeConfigurations = {
        "default" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit username homeDirectory; };
          modules = [ ./nix/home.nix ];
        };
        "jin-x86-linux"   = mkConfig "x86_64-linux";
        "jin-aarch-linux" = mkConfig "aarch64-linux";
        "jin-aarch-mac"   = mkConfig "aarch64-darwin";
      };
    };
}
```

### 4.2 ~/home_env_dotfiles/nix/home.nix
모든 모듈을 임포트하고 공통 설정을 관리한다. Ghostty 설정도 여기서 관리된다.

```nix
{ config, pkgs, ... }:

{
  home.username = "jin";
  home.homeDirectory = "/home/jin";
  home.stateVersion = "25.11"; 

  imports = [
    ./modules/shell.nix
    ./modules/packages.nix
    ./modules/neovim.nix
    ./modules/zellij.nix
    ./modules/git.nix
  ];

  targets.genericLinux.enable = true;
  fonts.fontconfig.enable = true;

  # Ghostty 설정
  xdg.configFile."ghostty/config".text = ''
    font-family = "Maple Mono NF"
    font-size = 12
    window-width = 150
    window-height = 60
    window-decoration = auto
    background-opacity = 0.85
    theme = Dracula
  '';

  programs.home-manager.enable = true;
}
```

### 4.3 ~/home_env_dotfiles/nix/modules/packages.nix
필수 패키지와 개발 도구를 설치한다.

```nix
{ config, pkgs, lib, ... }:

{
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];

  home.packages = with pkgs; [
    # [시스템 유틸 및 CLI 도구]
    neofetch btop ripgrep fd unzip lazygit lolcat lsb-release
    xclip xsel wl-clipboard ncdu duf tldr jq yq-go
    
    # [Neovim 보조 도구 (LSP/Parsers)]
    tree-sitter nil ast-grep lua51Packages.jsregexp
    gopls clang-tools yaml-language-server
    nodePackages.bash-language-server dockerfile-language-server-nodejs

    # 폰트
    maple-mono.NF nerd-fonts.ubuntu-mono monaspace nerd-fonts.jetbrains-mono

    # Node.js 관리 및 CLI
    fnm
    gemini-cli
  ];
}
```

### 4.4 ~/home_env_dotfiles/nix/modules/neovim.nix
Neovim 설정. TokyoNight 테마와 현대적인 플러그인들(oil.nvim, trouble.nvim, gitsigns 등)이 포함되어 있다.

```nix
{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true; 
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim
      which-key-nvim 
      nvim-web-devicons
      lualine-nvim
      neo-tree-nvim
      telescope-nvim
      nvim-treesitter.withAllGrammars 
      oil-nvim
      trouble-nvim
      nvim-osc52
      friendly-snippets
      # ... (기타 다수의 플러그인 및 LSP 설정)
    ];

    initLua = ''
      -- TokyoNight Theme, Beautiful Diagnostics UI, Telescope 설정 포함
      -- OSC 52 클립보드 동기화 (SSH 환경용)
      -- Alt+h/j/k/l: Neovim 창 이동 (Zellij Locked 모드와 호환)
      -- Space+f: 파일 찾기, Space+g: Live Grep
      -- Ctrl+n: Neo-tree 토글
      -- -: Oil.nvim (부모 디렉토리 열기)
      -- Ctrl+/: Toggle Floating Terminal (ToggleTerm)
      -- LSP 서버 (yaml, bash, docker 등) 자동 적용
    '';
  };
}
```

### 4.5 ~/home_env_dotfiles/nix/modules/shell.nix
Zsh, Starship, Eza, Bat, FZF 등 쉘 환경 설정. Direnv, Zellij 자동 실행, 그리고 **fnm 초기화** 로직이 포함됨.

```nix
{ config, pkgs, lib, ... }:

{
  # ... Starship (SSH 지원), Eza, Zoxide, Bat, FZF, Direnv 설정 ...

  programs.zsh = {
    enable = true;
    shellAliases = {
      # ls -> eza, cat -> bat 등 매핑
      hms = "home-manager switch --flake ~/home_env_dotfiles/#default --impure";
      zj = "zellij";
      nix-clean = "nix-env --delete-generations old && nix-store --gc";
      zj_shortcuts = "echo ... (도움말 출력) ...";
    };
    initContent = ''
      # SSH 환경 감지 및 Starship-SSH 적용
      # ...
      
      # fnm 초기화 (Node.js 버전 관리)
      if command -v fnm &>/dev/null; then
        eval "$(fnm env --use-on-cd --shell zsh)"
      fi

      # ... Zellij 자동 실행 (SSH 제외) 및 Welcome Message ...
      if [[ $- == *i* ]] && [[ -z "$ZELLIJ" ]] && ! is_vscode && ! is_ssh; then
        exec zellij
      fi
    '';
  };
}
```

### 4.6 ~/home_env_dotfiles/nix/modules/zellij.nix
Zellij 설정. 현대적인 UI와 세련된 색감(Modern Gruvbox)을 제공한다. Prefix로 **Ctrl+g**를 사용하여 Locked 모드(Vim 호환 모드)를 전환할 수 있다.

```nix
{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      theme = "modern-gruvbox";
      default_layout = "default";
      pane_frames = true;
      # ... 키바인딩(Alt+h,j,k,l 이동 등) ...
      keybinds = {
        normal = { "bind \"Ctrl g\"" = { SwitchToMode = "Locked"; }; };
        locked = { "bind \"Ctrl g\"" = { SwitchToMode = "Normal"; }; };
        # shared_except "locked" 에 Alt 키 이동 바인딩 포함
      };
    };
  };
}
```

## 5. 설치 및 적용

```bash
# 1. 레포지토리 클론 (또는 다운로드)
git clone <YOUR_REPO_URL> ~/home_env_dotfiles
cd ~/home_env_dotfiles

# 2. 변경된 파일 Git 인식 (Nix Flake 필수)
git add .

# 3. Home Manager 적용 (Native Linux & WSL 통합)
home-manager switch --flake .#jin -b backup

# 4. Node.js 설치 (fnm 이용)
fnm install --lts
fnm default lts-latest
```

## 6. 트러블슈팅

- **GPU Warning:** "Non-NixOS system..." 경고는 무시해도 되며, 하드웨어 가속이 필요하면 경고 메시지에 나온 `non-nixos-gpu-setup` 명령어를 `sudo`로 실행한다.
- **폰트 깨짐:** 터미널(Ghostty 등) 폰트를 `Maple Mono NF` 또는 `UbuntuMono Nerd Font`로 설정했는지 확인한다.
- **Vim 단축키 충돌:** NeoVim 사용 시 `Ctrl+g`를 눌러 Zellij를 **Locked 모드**로 전환하면 NeoVim의 모든 단축키를 그대로 사용할 수 있다.
- **패키지 업데이트:** `nix flake update` 후 `hms`를 실행한다.
