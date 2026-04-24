# [Environment Detection]
function is_ssh() { 
  [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" || -n "$SSH_CONNECTION" ]] && return 0
  [[ "$(ps -o comm= -p $PPID 2>/dev/null)" == "sshd" ]]
}
function is_docker() { [[ -e /.dockerenv ]] || grep -q "docker" /proc/1/cgroup 2>/dev/null; }
function is_vscode() { [[ -n "$VSCODE_IPC_HOOK_CLI" || -n "$VSCODE_PID" || "$TERM_PROGRAM" == "vscode" ]]; }

# [SSH Terminfo Fallback]
if is_ssh; then
  export TERMINFO_DIRS="$HOME/.terminfo:/usr/share/terminfo"
  if [[ "$TERM" == "xterm-ghostty" ]]; then
    if ! infocmp xterm-ghostty >/dev/null 2>&1; then export TERM=xterm-256color; fi
    export COLORTERM=truecolor
  fi
fi

# [Theme & Prompt Settings]
if is_ssh; then
  export STARSHIP_CONFIG="$HOME/.config/starship-ssh.toml"
elif is_docker; then
  export STARSHIP_CONFIG="$HOME/.config/starship-docker.toml"
fi

# [SSH Wrapper]
function ssh() {
  if [[ "$TERM" == "xterm-ghostty" || "$TERM_PROGRAM" == "Ghostty" ]]; then
    ghostty +ssh "$@"
  else
    TERM=xterm-256color COLORTERM=truecolor command ssh "$@"
  fi
}

# [Zellij Wrapper]
function zellij() {
  if is_ssh || is_docker; then command zellij --config "$HOME/.config/zellij/remote.kdl" "$@"; else command zellij "$@"; fi
}

# [Zellij Auto-start]
if [[ $- == *i* ]] && [[ -z "$ZELLIJ" ]] && ! is_vscode; then
  parent_proc=$(ps -p $PPID -o comm= 2>/dev/null)
  if [[ "$parent_proc" != "zellij" ]]; then
    if is_ssh; then exec zellij --config "$HOME/.config/zellij/remote.kdl"; else exec zellij; fi
  fi
fi
