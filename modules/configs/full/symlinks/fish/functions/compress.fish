function compress
  if [ -z $argv ]
    echo "Usage: compress videofile !"
  else
    cp $argv /tmp
    ffmpeg -i /tmp/$argv -vcodec libx265 -crf 28 /tmp/compressed-$argv
    mv /tmp/compressed-$argv $argv
    echo "Video compression finished !"
  end
end
