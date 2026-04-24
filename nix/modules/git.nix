{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = { name = "jin"; email = "jin10190220@gmail.com"; };
      init.defaultBranch = "main";
    };
  };
}
