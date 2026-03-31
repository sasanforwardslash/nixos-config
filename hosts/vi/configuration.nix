{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "vi";

  # Desktop
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.desktopManager.pantheon.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;

  # Fingerprint scanner
  services.fprintd.enable = true;
  security.pam.services.login.enable = true;
  security.pam.services.sudo.enable = true;
  security.pam.services.su.enable = true;

  environment.systemPackages = with pkgs; [
    fprintd
    libfprint
    usbutils
    vivaldi
  ];

  system.stateVersion = "25.11";
}
