function fn
  set path "/home/$USER/.config/fish/functions/"
  set _fn "ls $path | cut -d'/' -f7 | sed 's/.fish//g'"

  switch $argv
    case -h help --help
      printf "This is an helper function for functions !\n"
      echo "allows you to check all your fish functions & some help info."
      printf "\nUsage : \n\n"
      echo "fn -a       : get names of all functions"
      echo "fn -c       : get functions count "
      echo "fn/fn arg   : either choose/pass a function to get some info"
    case -a
      echo $_fn
    case -c
      printf "Functions count : %s\n" (echo $_fn |wc -w)
    case '*'
      if string match -qr $argv $_fn 2> /dev/null; or [ -z $argv ]
        set check_info ( fish -c $_fn | dmenu -p 'Choose a function : ')
        if not [ -z $check_info ]
          printf 'Checking help for Fn : "%s"\n' $check_info

          if not fish -c "$check_info -h" 2> /dev/null
            printf "Sorry this need documenting, till then try reading !\n\n"
            v $path$check_info.fish
          end
        end
      else
        error "Invalid use !"
      end
  end
end
