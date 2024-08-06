function gpush
  if [ -z "$argv" ]
    git push origin (gb | grep -e '*' | cut -d ' ' -f2)
  else if [ "$argv[1]" = "-f" ]
    read -P "Do a force Push ?" yes
    if [ $yes="" ]; or [ $yes=" " ]
      git push origin (gb | grep -e '*' | cut -d ' ' -f2) --force
    end
  else
    git push origin $argv
  end
end
