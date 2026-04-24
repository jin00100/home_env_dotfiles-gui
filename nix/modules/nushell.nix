{ config, pkgs, lib, ... }:

{
  programs.nushell = {
    enable = true;
    extraEnv = ''
      let is_ssh = (not ($env | get -o SSH_CLIENT | is-empty)) or (not ($env | get -o SSH_TTY | is-empty)) or (not ($env | get -o SSH_CONNECTION | is-empty))
      let is_docker = ("/.dockerenv" | path exists) or (if ("/proc/1/cgroup" | path exists) { (open /proc/1/cgroup | str contains "docker") } else { false })
      if ($is_ssh or $is_docker) { $env.STARSHIP_CONFIG = ($env.HOME | path join ".config" "starship-ssh.toml") }
    '';
    extraConfig = ''
      $env.config = { show_banner: false, edit_mode: vi }
      # simplified for safety
    '';
    shellAliases = {
      la = "ls -a";
      g  = "git";
      v  = "nvim";
    };
  };
}
