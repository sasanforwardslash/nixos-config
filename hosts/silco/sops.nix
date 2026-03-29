{
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      placeholder = {};
      cloudflare_api_token = {};
      netbird_setup_key = {};
      nextcloud_admin_password = {};
      nextcloud_db_password = {};
    };
  };
}
