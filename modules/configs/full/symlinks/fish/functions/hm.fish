function hm
  set pkgs_file "/home/$USER/.config/nixpkgs/pkgs/general.nix"
  switch $argv[1]
    case '-h'
      set_color blue
      echo "Usage: "
      set_color green
      echo "-h      :   help"
      echo "-a/i    :   add package"
      echo "-e      :   edit home-manager config"
      echo "-g      :   list generations"
      echo "-q      :   list home.packages"
      echo "-c      :   current generation"
      echo "-s      :   home-manager switch"
      echo "-x      :   remove pkg + hm -s "
      echo "-z      :   remove pkg, cleans up config"
      echo "-r      :   -r <num>, goes back <num> generations"
    case '-s' '' #when -s of nothing is passed
      cmd home-manager switch
    case '-e'
      cmd he
    case '-a' '-i'
      set pkgs_start (math 1+(grep -n -F "home.packages" $pkgs_file | cut -d":" -f1))

      if not [ "$argv[2]" = "" ]
        if [ (sed -n $pkgs_start'p' $pkgs_file | wc -w) -lt 7 ]
          set start_pkg (sed -n $pkgs_start'p' $pkgs_file | cut -f5 -d' ') #get first pkg in that line
          echo installing $argv[2]
          sed -i '/'"$start_pkg"'/ s/$/ '"$argv[2]/"'' $pkgs_file #append to the line with the first pkg
        else
          set pkg "\ \ $argv[2]" #spaces to be inserted
          sed -i "$pkgs_start i \ \ $pkg" $pkgs_file #spaces to be inserted
        end
        if home-manager switch
          echo "Package: $argv[2] is now available in your PATH"
        else
          set_color red
          echo "Failed to install package: $argv[2]"
          set_color green
          echo "Cleaning up config ..."
          set_color normal
          hm -z $argv[2]
        end
      else
        set_color red
        echo "missing <package> attribute."
      end
    case '-z' #for just cleaning the config
      if not [ "$argv[2]" = "" ]
        if grep $argv[2] $pkgs_file &> /dev/null
          set pkg_line (grep -n $argv[2] $pkgs_file | cut -d':' -f1)
          echo "Removing $argv[2] ..."
          if [ (sed -n $pkg_line'p' $pkgs_file | wc -w) -ne 1 ]
            sed -i 's/ '"$argv[2]"'//' $pkgs_file
          else
            sed -i "/$argv[2]/d" $pkgs_file
          end
        else
          set_color red
          echo "Package: $argv[2] not found in your $pkgs_file."
          set status 1 2> /dev/null #fails to change the readonly var still gets the job done
        end
      else
        set_color red
        echo "missing <package> attribute."
      end
    case '-x' #for doing a rebuild after cleaning
      if hm -z $argv[2]
        home-manager switch
        set_color green
        echo "Package: $argv[2] is now removed from your PATH"
      else
        set status 1 2>/dev/null #just passing from hm -z
      end
    case '-q'
      set start (cat $pkgs_file | grep -o 'packages .* \[' | cut -d" " -f4)
      set end "];"
      sed -n '/'"$start"'/,/'"$end"'/p' $pkgs_file | sed '1d;$d'
    case '-c'
      #cmd "home-manager generations | head -n 1 | tail -n 1"
      home-manager generations | head -n 1 | tail -n 1
    case '-g'
      cmd home-manager generations | bat
    case '-r'
      switch $argv[2]
        case ''
          set argv[2] 2
      end
      set gobackto (home-manager generations | head -n (math $argv[2]+1) |tail -n 1)
      echo "Reverting to Generation:" (echo $gobackto|cut -d' ' -f5)
      cmd (echo $gobackto|cut -d' ' -f7)/activate
    case '*'
      hm -h
  end
end
