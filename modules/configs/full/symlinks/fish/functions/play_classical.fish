function play_classical
  if not pgrep mpv
    notify-send --hint int:transient:1 "Playing some classical ❤️"
    mpv --force-window=no "https://live.musopen.org:8085/streamvbr0"
  else
    notify-send --hint int:transient:1 "Stopping the Classical play !"
    pkill mpv
  end
end
