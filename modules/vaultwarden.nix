{ ... }:
{
  services.vaultwarden.config = {
    enable = true;
    SIGNUPS_ALLOWED = true;
    DOMAIN = "https://localhost:6767";
    ROCKET_ADDRESS = "127.0.0.1";
    ROCKET_PORT = 6767;

    backupDir = "/var/backup/vaultwarden";
  };
}
