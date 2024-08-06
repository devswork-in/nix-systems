function picomSwitch
  if pidof picom &>/dev/null
    notify-send --hint int:transient:1 "Picom: disabled"
    pkill picom
  else
    notify-send --hint int:transient:1 "Picom: enabled"
    picom &
  end
end
