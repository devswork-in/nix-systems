{ pkgs, ... }:

{
  # MySQL service - disabled at boot to improve boot time
  # To start when needed: sudo systemctl start mysql
  services.mysql = {
    enable = false;  # Changed to false - start manually when needed
    package = pkgs.mariadb;
  };
}
