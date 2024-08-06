function redshiftSwitch
  systemctl --user is-active --quiet redshift.service && systemctl --user stop redshift.service || systemctl --user start redshift.service
end
