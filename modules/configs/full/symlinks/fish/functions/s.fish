function s
  switch $argv[1]
    case '-*'
      switch $argv[1]
        case '-yv'
          yt $argv[2]
        case '-ya'
          ytfzf -m $argv[2]
        case '-s'
          set run ""
          if [ $argv[3] != "" ] &>/dev/null
            set run "grep -rnw $argv[2] -e $argv[3]"
          else
            set run "grep -rnw './' -e $argv[2]"
          end
          set run $run" | fzf | cut -d' ' -f1 | sed 's/:/ +/;s/://' "
          set checkFile (eval $run)
          [ -f (echo $checkFile|cut -d' ' -f1) ] && $EDITOR (echo $checkFile | cut -d' ' -f1) (echo $checkFile | cut -d ' ' -f2)
        case '-a'
          if string match -qr '^[0-9]+$' $argv[2] #usage: s -a 360 $query
            ani-cli -q $argv[2] $argv[3]
          else
            ani-cli $argv[2]
          end
        case '-p'
          mpv (bash -c 'find ~/ -type f | grep -E "\.mkv$|\.gif$|\.webm$|\.flv$|\.vob$|\.ogg$|\.ogv$|\.drc$|\.gifv$|\.mng$|\.avi$|\.mov$|\.qt$|\.wmv$|\.yuv$|\.rm$|\.rmvb$|/.asf$|\.amv$|\.mp4$|\.m4v$|\.mp*$|\.m?v$|\.svi$|\.3gp$|\.flv$|\.f4v$"' | fzf)
        case '-l'
          printf "From nix-locate:\n\n"
          nix-locate $argv[2]; or echo "Seems to be 1st time .." && echo "Running nix-index first !" && line && nix-index && nix-locate $argv[2]
        case '-f'
          set file (fzf -q "$argv[2]")
          echo $file | clip
          v $file
        case '-w'
          switch $argv[2]
            case '!g'
              echo "From the WEB 2.0:"
              echo "Google results:"
              googler $argv[3]
            case '!*'
              echo "Searching $argv[3] @"(echo $argv[2]|cut -d! -f2 )
              ddgr $argv[2] $argv[3] | head -n 1
            case '*'
              echo "From the WEB 2.0:"
              echo "Duckduckgo results:"
              ddgr $argv[2]
          end
        case '-h'
          printf "What this function can do ?\n\n"
          echo "s query                 : does nix-search, nix-locate if nix-search fails"
          echo "s -p query              : does local audio/video search,plays via mpv"
          echo "s -l query              : does nix-locate, find libs"
          echo "s -a query              : does ani-cli search"
          echo "s -a 360/480/*** query  : does ani-cli search with quality"
          echo "s -ya query             : does yt-audio search"
          echo "s -yv query             : does yt-video search"
          echo "s -s query              : does files search for the passed string"
          echo "s -s path query         : does files search for the passed string in requested path"
          echo "s -f query              : does a file search, opens as per function v and copies path to clipboard"
          echo "s -w query              : does WEB search(ddg results)"
          echo "s -w !g query           : does WEB search(google results)"
          echo "s -w !domain            : does web search on domain specified(e.g !google hello: searches hello on google.com), opens on browser"
          echo "s -h                    : help menu"
        case '*'
          s -h
      end
    case ''
      s -h
    case '*'
      printf "From nix search:\n\n" && nix search $argv 2>/dev/null; or line && printf "\nFrom nix-locate:\n\n" && nix-locate bin/$argv && [ (nix-locate bin/$argv | wc -l) -gt 0 ]
  end
end
