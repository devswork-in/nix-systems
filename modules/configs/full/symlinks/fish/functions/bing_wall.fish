
function bing_wall
  set img_today "https://www.bing.com"(curl -sL https://www.bing.com | grep -Eo '/th\?id=[a-zA-Z0-9?%.?%_?%-]*' |grep '1080' | head -n 1)
  set wall_dir "/tmp/bing_wall"

  if ping -c 1 google.com &> /dev/null
    echo "Checking for an Internet connection ..."\n
    echo "Fetching today's image !"
    rm -rf $wall_dir && mkdir -p $wall_dir
    wget -q -P $wall_dir $img_today
    mv (readlink -f $wall_dir/*) $wall_dir/(readlink -f $wall_dir/*|cut -d'.' -f2).jpg
    feh --bg-fill $wall_dir/*
    mv $wall_dir/* $WALLPAPERS/
  else
    echo "Unable to connect to the internet"
  end
end
