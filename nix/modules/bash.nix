{ config, pkgs, lib, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = { };
    initExtra = ''
      ${builtins.readFile ./shell-common.sh}
      
      # Optional: if you have a welcome script, you can run it here
      # if [[ $- == *i* ]]; then welcome-msg; fi

      if command -v fnm &>/dev/null; then eval "$(fnm env --use-on-cd --shell bash)"; fi
    '';
  };
}
