function line
  for i in (seq 1 $COLUMNS)
    tput smacs
    printf "%s" 's'
    tput rmacs
  end
  printf "\n"
end
