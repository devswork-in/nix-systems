function msgUntil
  if [ (echo $argv | wc -w) -lt 3 ]
    echo "Usage:"
    echo "msgUntil file Title message : file is a temp file created from calling function, run till it exists"
    return 1
  end
  set anim "."
  while [ -f $argv[1] ]
    notify-send "$argv[2] $msgvar" "$argv[3] $anim" -h string:x-canonical-private-synchronous:anything
    sleep 1
    if string match $anim "." &>/dev/null
      set anim ".."
    else if string match $anim ".." &>/dev/null
      set anim "..."
    else
      set anim "."
    end
  end
  pkill dunst #stop the notification server
end
