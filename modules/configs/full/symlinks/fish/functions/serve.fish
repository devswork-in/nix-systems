function serve
  if [ -z $argv[1] ]
    echo "Usage : "\n
    echo "serve file    :   hosts the file on bin.creator54.me"
    echo "serve -d file :   removes the file hosted on bin.creator54.me"
  else if [ $argv[1] = "-d" ]
    echo "Removing $argv[2] .."
    ssh $NIX -i $server_key -t "rm -rf ~/website-stuff/bin/$argv[2]" && echo "File is removed !"
  else
    set url "https://bin.creator54.me/$argv"
    rsync -e "ssh -i $server_key" $argv -aPvz $NIX:~/website-stuff/bin/
    echo "File is shared @ $url" && echo $url | clip
  end
end
