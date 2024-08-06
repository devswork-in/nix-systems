function winSwitch
  set Path "/home/$USER/.config/nixpkgs"
  set currentWM (cat $Path/home.nix | grep "./wm" | head -n 1 | cut -d"/" -f3 | cut -d"." -f1)
  set allWM (ls $Path/wm/ | grep -v "wm-pkgs\|$currentWM" | cut -d"." -f1) #becomes one string now so can't use in selectedWM
  set selectedWM (ls $Path/wm/ | grep -v "wm-pkgs\|$currentWM" | cut -d"." -f1 | dmenu -p " Select Window Manager ["(string upper $currentWM)"]: ") #selectWM from available window managers
  set notifycheck (mktemp) #run msgUntil till this file exists
  #set output ""

  if contains $selectedWM $allWM ;and ! [ -z $selectedWM ]
    fish -c "msgUntil $notifycheck 'Home Manager' 'Updating config '" &
    sed -i "s/$currentWM/$selectedWM/" $Path/home.nix #update WM
    set currentWM (string upper $currentWM)
    set selectedWM (string upper $selectedWM)
    home-manager switch -b backup --flake "$Path/#laptop" --impure
    #eval $output #doing eval so removing tempfile happens fater this.
    rm -rf $notifycheck #happening way to fast
    sleep 1 #cuz just killed dunst
    notify-send "Switching from $currentWM -> $selectedWM"
    sleep 1
    pkill X
  end
end
