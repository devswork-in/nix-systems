function pull
  if [ (count $argv) -eq 1 ]
    connect_me -n; rsync -e "ssh -i $server_key" -chavzP $SERVER:~/$argv[1] .
    #scp -i $server_key -rp $SERVER:/home/creator54/$argv[1] .
  else
    connect_me -n ; rsync -e "ssh -i $server_key" -chavzP $SERVER:~/$argv[1] $argv[2]
    #scp -i $server_key -rp $SERVER:/home/creator54/$argv[1] $argv[2]
  end
end
