{ config, pkgs, lib, user, home-manager, nix-homebrew, ... }:
{
  imports = [
    ../common
  ];

  system = {
    stateVersion = "24.05";
  };
}
