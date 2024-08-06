function record
  set name (echo (date '+%a-%F')-(ls ~/Screenrecords/| grep (date '+%a-%F')|count))
  set quality "1920"
  # if string match -qr 'vcam' $argv
  #     cmd ffmpeg -f x11grab -i $DISPLAY.0 -i /dev/video0
  #     ~/Screenrecords/$name+cam.mkv needs fixes
  set filename "/home/$USER/Screenrecords/$name"
  if string match -qr 'v|video|no audio' $argv
    cmd ffmpeg -f x11grab -i $DISPLAY.0 $filename.mkv
  else if string match -qr 'cam|camera' $argv
    cmd ffmpeg -i /dev/video0 $filename-cam.mkv
  else if string match -qr 'gif' $argv
    if not [ -z "$argv[2]" ]
      set quality $argv[2]
      end
      record
      set filename /home/$USER/Screenrecords/(ls -c ~/Screenrecords | head -n 1|cut -d'.' -f1)
      cmd ffmpeg  -t 44 -i $filename.mkv -vf "fps=10,scale=$quality:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 $filename.gif;rm -rf 
$filename.mkv
  else
    cmd ffmpeg -f x11grab -i $DISPLAY.0 -f alsa -i default -c:v libx264 -c:a flac $filename.mkv #1 is for computer audio, 2 is for mic generally
  end
end
