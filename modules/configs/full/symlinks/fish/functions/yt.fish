function yt
  if echo $argv[1] | grep '-' &> /dev/null
    switch $argv[1]
      case '-y'
        ytfzf -t -s $argv[2] $argv[3]
      case '-d'
        echo 'yt-dlp -f 251+247 $argv[2]' > yt-resume
        yt-dlp -f 251+247 $argv[2] && rm -rf yt-resume #thus if this file exists shell knows download incomplete thus asks to complete
      case '-F'
        yt-dlp -F $argv[2]
      case '-f'
        yt-dlp -f $argv[2] $argv[3]
      case '*'
        echo "Usage: "
        echo "yt <link>                 : browse via ytfzf script"
        echo "yt -y <flag> <link>           : browse via ytfzf script with flags"
        echo "yt -d <link>              : start video download default quality "
        echo "yt -f <link>              : use specified format to download"
        echo "yt -F <link>              : show available formats"
    end
  else
    ytfzf $argv
  end
end
