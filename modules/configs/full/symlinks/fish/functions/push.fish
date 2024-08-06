function push
  if [ -z $argv[1] ]
    echo "Usage : "\n
    echo "push somefile     : pushes the file to selected server"
    echo "push somefile dir : pushes the file to selected server,specified directory"
  else
    if [ -z $argv[2] ]
      #scp -i $server_key -rp $argv[1] $SERVER:/home/creator54
      connect_me -n ; rsync -e "ssh -i $server_key" $argv[1] -aPvz $SERVER:~/
    else
      #scp -i $server_key -rp $argv[1] $SERVER:/$argv[2] # -r for folders preserve times and modes of the original files and subdirectories
      connect_me -n ; rsync -e "ssh -i $server_key" $argv[1] -aPvz $SERVER:$argv[2]
    end
  end
end
