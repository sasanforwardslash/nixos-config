{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./sops.nix
    ./containers.nix
  ];

  users.groups.dialout.members = [ "sasan" ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  networking.hostName = "silco";

  systemd.defaultUnit = lib.mkForce "multi-user.target";

  # Virtualization
  virtualisation.docker.enable = true;

  # Desktop
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
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

  # Remote access
  services.x2goserver.enable = true;
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "xfce4-session";
  services.xrdp.openFirewall = true;
  services.openssh.enable = true;

  # Networking
  networking.firewall.allowedTCPPorts = [ 8123 8086 8085 8084 8081 5580 3000 443 80 53 ];
  networking.firewall.allowedUDPPorts = [ 5353 443 53 ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };


  system.stateVersion = "25.11";
}
