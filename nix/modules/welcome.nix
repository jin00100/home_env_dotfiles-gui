{ config, pkgs, lib, ... }:

{
  programs.zsh.initContent = lib.mkMerge [
    ''
      # ---------------------------------------------------------
      # [New] Welcome Message for Zellij Sessions or SSH
      # ---------------------------------------------------------
      if [[ -n "$ZELLIJ" ]] || is_ssh; then
        # Disable line wrapping
        printf "\e[?7l"

        # Fast OS detection
        local os_name="Linux"
        if [[ -f /etc/os-release ]]; then
          os_name=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)
        fi

        # Determine which ASCII art to show
        if is_ssh; then
          # SSH: Always show the small version with Gemini gradient
          echo -e "\x1b[38;2;66;133;244m ███             █████ █████ ██████   █████\x1b[0m"
          echo -e "\x1b[38;2;90;117;240m░░░███          ░░███ ░░███ ░░██████ ░░███\x1b[0m"
          echo -e "\x1b[38;2;114;102;235m  ░░░███         ░███  ░███  ░███░███ ░███\x1b[0m"
          echo -e "\x1b[38;2;138;86;231m    ░░░███       ░███  ░███  ░███░░███░███\x1b[0m"
          echo -e "\x1b[38;2;161;71;226m     ███░        ░███  ░███  ░███ ░░██████\x1b[0m"
          echo -e "\x1b[38;2;185;55;222m   ███░    ███   ░███  ░███  ░███  ░░█████\x1b[0m"
          echo -e "\x1b[38;2;209;39;217m ███░     ░░████████   █████ █████  ░░█████\x1b[0m"
          echo -e "\x1b[38;2;234;67;53m░░░        ░░░░░░░░   ░░░░░ ░░░░░    ░░░░░\x1b[0m"
        elif command -v lolcat &>/dev/null; then
          # Local Zellij: Show large version with lolcat
          cat << 'EOF' | lolcat 
                                                                                                                 

 ███             █████ █████ ██████   █████
░░░███          ░░███ ░░███ ░░██████ ░░███ 
  ░░░███         ░███  ░███  ░███░███ ░███ 
    ░░░███       ░███  ░███  ░███░░███░███ 
     ███░        ░███  ░███  ░███ ░░██████ 
   ███░    ███   ░███  ░███  ░███  ░░█████ 
 ███░     ░░████████   █████ █████  ░░█████
░░░        ░░░░░░░░   ░░░░░ ░░░░░    ░░░░░ 
EOF
        else
          # Local Zellij (no lolcat): Show small version with Gemini gradient
          echo -e "\x1b[38;2;66;133;244m ███             █████ █████ ██████   █████\x1b[0m"
          echo -e "\x1b[38;2;90;117;240m░░░███          ░░███ ░░███ ░░██████ ░░███\x1b[0m"
          echo -e "\x1b[38;2;114;102;235m  ░░░███         ░███  ░███  ░███░███ ░███\x1b[0m"
          echo -e "\x1b[38;2;138;86;231m    ░░░███       ░███  ░███  ░███░░███░███\x1b[0m"
          echo -e "\x1b[38;2;161;71;226m     ███░        ░███  ░███  ░███ ░░██████\x1b[0m"
          echo -e "\x1b[38;2;185;55;222m   ███░    ███   ░███  ░███  ░███  ░░█████\x1b[0m"
          echo -e "\x1b[38;2;209;39;217m ███░     ░░████████   █████ █████  ░░█████\x1b[0m"
          echo -e "\x1b[38;2;234;67;53m░░░        ░░░░░░░░   ░░░░░ ░░░░░    ░░░░░\x1b[0m"
          echo ""
        fi

        # Original system info colors
        echo -e "\x1b[1;31m $os_name\x1b[0m"
        echo -e "\x1b[1;33m HOST      : $(uname -n)\x1b[0m"
        echo -e "\x1b[1;32m SESSION   : Zellij (Modern Terminal Workspace)\x1b[0m"
        echo -e "\x1b[1;34m Kernel    : $(uname -r)\x1b[0m"
        echo -e "\x1b[1;35m Date      : $(date +'%Y-%m-%d %H:%M:%S')\x1b[0m"
        echo -e "\x1b[1;36m Shell     : $(zsh --version | awk '{print $1, $2}')\x1b[0m"
        echo -e "\x1b[1;37m Who       : $(whoami)\x1b[0m"

        echo -e "\nWelcome to \x1b[94mZsh\x1b[0m, \x1b[1m$USER!\x1b[0m"

        # Re-enable line wrapping
        printf "\e[?7h"
      fi      
    ''
  ];
}
