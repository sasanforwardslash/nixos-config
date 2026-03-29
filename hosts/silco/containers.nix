{ config, ... }:
{
  systemd.tmpfiles.rules = [
    "d /var/lib/glance 0755 root root -"
		"d /var/lib/homeassistant 0755 root root -"
		"d /var/lib/homeassistant/config 0755 root root -"
    "d /var/lib/otbr 0755 root root -"
    "d /var/lib/matter 0755 root root -"
    "d /var/lib/adguard 0755 root root -"
    "d /var/lib/adguard/work 0755 root root -"
    "d /var/lib/adguard/conf 0755 root root -"
    "d /var/lib/caddy 0755 root root -"
    "d /var/lib/caddy/data 0755 root root -"
    "d /var/lib/caddy/config 0755 root root -"
    "d /var/lib/netbird 0755 root root -"
    "d /mnt/primary 0755 root root -"
    "d /mnt/mirror 0755 root root -"
    "d /mnt/primary 0755 sasan users -"

	];

	virtualisation.oci-containers = {
    backend = "docker";
		containers = {

		  hello = {
        image = "nginx:alpine";
				ports = [ "8080:80" ];
        autoStart = true;
			};

			glance = {
        image = "glanceapp/glance:latest";
				ports = [ "8081:8080" ];
				autoStart = true;
				volumes = [
				  "/var/lib/glance/glance.yaml:/app/config/glance.yml"
				];
        extraOptions = [
          "--pid=host"
        ];
			};

      adguard = {
        image = "adguard/adguardhome:latest";
        autoStart = true;
        ports = [
          "53:53/tcp"
          "53:53/udp"
          "3000:3000/tcp"
          "192.168.2.206:8086:8086/tcp"
        ];
        volumes = [
          "/var/lib/adguard/work:/opt/adguardhome/work"
          "/var/lib/adguard/conf:/opt/adguardhome/conf"
        ];
      };

      caddy = {
        image = "ghcr.io/serfriz/caddy-cloudflare:latest";
        autoStart = true;
        ports = [
          "80:80"
          "443:443"
          "443:443/udp"
        ];
        volumes = [
          "/var/lib/caddy/Caddyfile:/etc/caddy/Caddyfile"
          "/var/lib/caddy/data:/data"
          "/var/lib/caddy/config:/config"
        ];
        environmentFiles = [ config.sops.secrets.cloudflare_api_token.path ];
      };

      netbird = {
        image = "netbirdio/netbird:latest";
        autoStart = true;
        extraOptions = [
          "--network=host"
          "--cap-add=NET_ADMIN"
          "--cap-add=SYS_ADMIN"
          "--cap-add=SYS_RESOURCE"
          "--device=/dev/net/tun:/dev/net/tun"
        ];
        volumes = [
          "/var/lib/netbird:/etc/netbird"
        ];
        environmentFiles = [ config.sops.secrets.netbird_setup_key.path ];
      };

      otbr = {
        image = "ghcr.io/ownbee/hass-otbr-docker:latest";
        autoStart = true;
        extraOptions = [
          "--privileged"
          "--network=host"
          "--device=/dev/serial/by-id/usb-SONOFF_SONOFF_Dongle_Lite_MG21_7a43d3a954a2ef11ac21946661ce3355-if00-port0:/dev/ttyUSB0"
          "--device=/dev/net/tun:/dev/net/tun"
        ];
        environment = {
          DEVICE = "/dev/ttyUSB0";
          BAUDRATE = "460800";
          FLOW_CONTROL = "0";
          BACKBONE_IF = "enp1s0";
          OTBR_REST_PORT = "8084";
          OTBR_WEB_PORT = "8085";
          OTBR_MDNS = "host";
        };
      };

      matter-server = {
        image = "ghcr.io/home-assistant-libs/python-matter-server:stable";
        autoStart = true;
        volumes = [
          "/var/lib/matter:/data"
          "/run/dbus:/run/dbus:ro"
        ];
        extraOptions = [
          "--network=host"
          "--security-opt=apparmor=unconfined"
        ];
      };

			homeassistant = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
				autoStart = true;
				environment = {
          TZ = "Europe/Berlin";
				};
				volumes = [
          "/var/lib/homeassistant/config:/config"
          "/run/dbus:/run/dbus:ro"
				];
				extraOptions = [
  				"--privileged"
          "--network=host"
  				"--device=/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_3c0ae4955f4eef1193bc45b3174bec31-if00-port0:/dev/ttyUSB1"
				];
			};

		};
	};
}
