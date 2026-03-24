{ config, pkgs, ... }:
{
  home.username = "sasan";
  home.homeDirectory = "/home/sasan";

  # Home Manager release - don't change unless HM says to
  home.stateVersion = "24.11";

  home.packages = [];

  programs.home-manager.enable = true;
}

