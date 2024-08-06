function work
  set vnc_link "http://13.126.70.193:8082/vnc/host/172.17.0.3/port/50000/?nginx=&path=proxy/172.17.0.3:50000/websockify&view_only=false"
  set mentor_url "mentor.crio.do"
  set helpdesk "https://help.crio.do/a/tickets/filters/search?orderBy=created_at&orderType=desc&q[]=group%3A%5B82000656204%2C82000657057%2C82000657058%5D&q[]=status%3A%5B0%5D&ref=unresolved"
  set crio_urls "https://www.crio.do/learn/track/TRACK_MASTERS_QA/" (cat ~/workspace_url)
  set extra_urls "mail.google.com" "web.whatsapp.com"
  firefox $mentor_url "https://trello.com/b/kDa6KFCZ/work" #workspace 1
  xdotool key Super_L+shift+1
  google-chrome-stable $helpdesk  #workspace 1
  xdotool key Super_L+shift+1
  google-chrome-stable --new-window $vnc_link  #workspace 2
  xdotool key Super_L+shift+2
  google-chrome-stable --new-window $crio_urls  #workspace 2
  xdotool key Super_L+shift+2
  google-chrome-stable --new-window $extra_urls  #workspace 3
  xdotool key Super_L+shift+3
end
