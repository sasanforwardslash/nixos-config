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
  networking.firewall.allowedTCPPorts = [ 22000 8384 8123 8087 8086 8085 8084 8083 8081 5580 5432 3000 443 80 53 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 5353 443 53 ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Storage
  fileSystems."/mnt/primary" = {
    device = "/dev/disk/by-uuid/2fca864a-bf1a-4557-9663-d47936ee76b7";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  fileSystems."/mnt/mirror" = {
    device = "/dev/disk/by-uuid/080e5efa-b36c-438e-98d2-a1945eb0cd97";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  systemd.services.mirror-sync = {
    description = "Mirror primary drive to mirror drive";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.rsync}/bin/rsync -av --delete /mnt/primary/ /mnt/mirror/";
    };
  };

  systemd.timers.mirror-sync = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "silco";
        "server role" = "standalone server";
        "log level" = "1";
        "min protocol" = "SMB2";
        "ntlm auth" = "yes";
      };
      primary = {
        "path" = "/mnt/primary";
        "browseable" = "yes";
        "writeable" = "yes";
        "valid users" = "sasan";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
    interface = "enp1s0";
  };

  system.stateVersion = "25.11";
}
