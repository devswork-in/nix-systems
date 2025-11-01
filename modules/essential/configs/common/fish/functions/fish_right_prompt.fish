function fish_right_prompt
  set -l exit_code $status
  if test $exit_code -ne 0
    set_color red
  else
    set_color green
  end
  printf '%d' $exit_code
  if [ "$dols" = "true" ]
    set_color yellow
    # Calculate uptime from /proc/uptime for reliable formatting
    set -l uptime_str (awk '{days=int($1/86400); hours=int(($1%86400)/3600); mins=int(($1%3600)/60); if(days>0) printf "%d days %02d:%02d", days, hours, mins; else printf "%02d:%02d", hours, mins}' /proc/uptime)
    printf '| UP: %s  ' $uptime_str
  end
  set_color normal
end