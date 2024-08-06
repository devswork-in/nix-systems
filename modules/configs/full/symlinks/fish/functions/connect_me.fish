function connect_me
  set -gx SERVER (servers)
  if [ -z $argv ]
    ssh $SERVER -i $server_key
  end
end
