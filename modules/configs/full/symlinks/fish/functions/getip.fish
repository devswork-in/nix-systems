function getip
  if string match -qr 'github.io' $argv
    dig $argv|sed -n 12p|cut -f3
  else
    dig $argv | sed -n 12p | cut -f6
  end
end
