{ config, pkgs, lib, ... }:

{
  imports = [
    ./shell-utils.nix
    ./welcome.nix
    ./zsh.nix
  ];
}
