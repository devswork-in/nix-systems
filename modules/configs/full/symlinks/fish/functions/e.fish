function e
  switch $argv[1]
  case '-d'
    c $argv[2] && $EDITOR (echo $argv[2]|sed 's/^.*\///')
  case '*'
    if string match (echo $argv | cut -d'.' -f2) cpp c cxx &> /dev/null
      cdev $argv
    else
      $EDITOR $argv
    end
  end
end
