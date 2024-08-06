function startVpn
  set server (servers)
  nix-shell -p sshuttle --run "sshuttle -r $server -x $(echo $server | cut -d'@' -f2) 0/0 -vv --ssh-cmd 'ssh -i $server_key'"
end
