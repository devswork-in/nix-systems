function fpkg #search for related Package available via nixpkgs
  set pkgs (s $argv[1] | cut -d' ' -f1 | grep ".out" | sed 's/.out//g')
  set pkgcount (echo $pkgs | wc -w)
  for x in (seq 1 $pkgcount)
    echo $x $pkgs[$x]
  end
  if [ $pkgcount -gt 0 ]
    echo
    read -P "Select a Package to install : " pkgid
    if not set -q $pkgid;or [ string match -qr '^-?[0-9]+(\.?[0-9]*)?$' -- $pkgid && [ $pkgid -gt 0 ] && [ $pkgid -le $pkgcount ] ]
      i $pkgs[$pkgid]
    else
      set_color red
      echo "Aborted !"
    end
  else
    set status 1 &>/dev/null #does the job
  end
end
