{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.wireguard-tools ];
  networking.firewall.checkReversePath = false;

  # only for wireguard https://nixos.wiki/wiki/WireGuard
  # create the /etc/wireguard/ folder and move the $domain.conf there
  # wg-quick up $domain [CLI]
  # sudo nmcli connection import type wireguard file /etc/wireguard/$domain.conf
  # The new VPN connection should be available, you still have to click on it to activate it.
  # In NetworkManger applet GUI
}
