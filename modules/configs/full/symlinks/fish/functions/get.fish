function get
  if [ -z $argv ]
    echo "You do need to pass a link to download !"
  else if string match -qr "github.com" $argv
    git clone $argv && cd  (echo $argv |cut -d'/' -f5)
  else if string match -qr ".mp3|.mp4|.mkv|.zip|.tar|.gz" $argv
    axel -n 10 $argv #this makes 10 connections, thus speeds the download by 10x the general connection
  else
    wget -r –level=0 -E –ignore-length -x -k -p -erobots=off -np -N "$argv" and echo "Fetched $argv" or echo "Couldn't fetch !"
  end
end
