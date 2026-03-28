{ ... }:
{
  systemd.tmpfiles.rules = [
    "d /var/lib/glance 0755 root root -"
		"d /var/lib/homeassistant 0755 root root -"
		"d /var/lib/homeassistant/config 0755 root root -"
    "d /var/lib/otbr 0755 root root -"
    "d /var/lib/matter 0755 root root -"
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
