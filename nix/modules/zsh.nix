{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "emacs";

    # [.zshenv] Loaded first (Terminal compatibility fallbacks)
    envExtra = ''
      # [Terminal Compatibility] Fallback to standard if xterm-ghostty terminfo is missing
      if [[ "$TERM" == "xterm-ghostty" ]] && ! command -v infocmp &>/dev/null; then
        export TERM=xterm-256color
      elif [[ "$TERM" == "xterm-ghostty" ]] && ! infocmp xterm-ghostty &>/dev/null; then
        export TERM=xterm-256color
      fi
    '';

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # [Ghostty] Shell Integration (ONLY if running INSIDE Ghostty)
        if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
          if [[ -f "/usr/share/ghostty/shell-integration/zsh/ghostty-integration" ]]; then
            source "/usr/share/ghostty/shell-integration/zsh/ghostty-integration"
          elif [[ -f "$HOME/.nix-profile/share/ghostty/shell-integration/zsh/ghostty-integration" ]]; then
            source "$HOME/.nix-profile/share/ghostty/shell-integration/zsh/ghostty-integration"
          fi
        fi

        if [[ "$TERM" == "zellij" ]]; then
          export TERM=xterm-256color
          export ZELLIJ_SKIP_AUTOSTART=true
        fi

        # [SSH Detection] More robust check
        function is_ssh() {
          [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" || -n "$SSH_CONNECTION" ]] || \
          [[ "$(ps -o comm= -p $PPID 2>/dev/null)" == "sshd" ]]
        }

        if is_ssh; then
          export STARSHIP_CONFIG="$HOME/.config/starship-ssh.toml"
          # Cache IP address for Starship to avoid lag on every prompt render
          export SSH_LOCAL_IP=$(ip -4 addr show scope global 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1 || hostname)
        fi
      '')
      ''
        # fnm initialization code
        if command -v fnm &>/dev/null; then
          eval "$(fnm env --use-on-cd --shell zsh)"
        fi

        # --- Autocompletion Caching for Performance ---
        mkdir -p ~/.zsh_cache

        # Helm 自动补全 (Cached)
        if command -v helm &>/dev/null; then
          if [[ ! -f ~/.zsh_cache/helm_completion ]]; then
            helm completion zsh > ~/.zsh_cache/helm_completion 2>/dev/null
          fi
          source ~/.zsh_cache/helm_completion
        fi

        # Kubectl 自动补全 (Cached)
        if command -v kubectl &>/dev/null; then
          if [[ ! -f ~/.zsh_cache/kubectl_completion ]]; then
            kubectl completion zsh > ~/.zsh_cache/kubectl_completion 2>/dev/null
          fi
          source ~/.zsh_cache/kubectl_completion
        fi
        
        export PATH=$HOME/.local/bin:$PATH

        # [Key Bindings] Enhancing bindings for broader terminal compatibility
        bindkey '^[[A' history-substring-search-up    # Arrow Up
        bindkey '^[[B' history-substring-search-down  # Arrow Down
        bindkey '^[OA' history-substring-search-up    # Arrow Up (Application Mode)
        bindkey '^[OB' history-substring-search-down  # Arrow Down (Application Mode)

        # ---------------------------------------------------------
        # [New] Zellij Autostart
        # ---------------------------------------------------------
        function is_vscode() {
          [[ -n "$VSCODE_IPC_HOOK_CLI" || -n "$VSCODE_PID" || "$TERM_PROGRAM" == "vscode" ]]
        }

        # Interactive Shell + Outside Zellij + Not VSCode + Not SSH -> Autostart
        if [[ $- == *i* ]] && [[ -z "$ZELLIJ" ]] && [[ -z "$ZELLIJ_SKIP_AUTOSTART" ]] && ! is_vscode && ! is_ssh; then
          # Start a new session (prevents duplication)
          exec zellij
        fi
      ''
    ];

    # Native Nix Zsh plugins (faster startup than oh-my-zsh)
    plugins = [
      {
        name = "zsh-history-substring-search";
        src = "${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search";
      }
    ];

    shellAliases = {
      # Kubernetes & Helm Shortcuts
      k = "kubectl";
      h = "helm";

      ls = "eza";
      ll = "eza -l --icons --git -a";
      lt = "eza --tree --level=2 --long --icons --git";
      
      # [New] cat -> bat mapping
      cat = "bat";
      
      # [New] Clipboard copy alias
      tocb = "xclip -selection clipboard";

      hms = "home-manager switch --flake ~/home_env_dotfiles/#default --impure";
      vi = "nvim";
      vim = "nvim";
      zj = "zellij";
      
      # [New] Nix cleanup alias
      nix-clean = "nix-env --delete-generations old && nix-store --gc";

      zj_shortcuts = ''echo -e "\033[1;34m=== Zellij Custom Shortcuts (Tmux Style) ===\033[0m" && \
                        echo -e "\033[1;33m[ Quick Actions (Alt Key) ]\033[0m" && \
                        echo "  Alt + n       : New Pane (Right)" && \
                        echo "  Alt + h/j/k/l : Move focus (Left/Down/Up/Right)" && \
                        echo "  Alt + i/o     : Move Tab (Prev/Next)" && \
                        echo "  Alt + =/-     : Resize Pane (Increase/Decrease)" && \
                        echo -e "\033[1;33m[ Core Modes (Prefix) ]\033[0m" && \
                        echo "  Ctrl + g      : LOCKED Mode (Essential for NeoVim!)" && \
                        echo "  Ctrl + s      : SCROLL/COPY Mode (Like tmux prefix + [)" && \
                        echo "                  -> v: Select, y/Enter: Copy" && \
                        echo "  Ctrl + p      : PANE Mode (Split, Resize, etc.)" && \
                        echo "  Ctrl + t      : TAB Mode (New, Rename, etc.)" && \
                        echo "  Ctrl + n      : RESIZE Mode" && \
                        echo "  Ctrl + o      : SESSION Mode" && \
                        echo "  Ctrl + q      : QUIT Zellij" && \
                        echo -e "\033[1;32mTip: Bottom bar changes based on these modes!\033[0m" '';
    };
  };
}
