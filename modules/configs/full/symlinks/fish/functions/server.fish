function server
  set -gx SERVER (servers)
  if [ -z $argv ]
    sftp -i ~/.ssh/webserver $SERVER
  end
end
