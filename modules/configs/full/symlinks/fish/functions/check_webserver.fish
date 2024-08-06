function check_webserver
  cmd curl -s -I $argv | grep server
end
