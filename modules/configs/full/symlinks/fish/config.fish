set -gx TERM kitty
set -gx TERMINAL $TERM
set -gx BROWSER firefox
set -gx WALLPAPERS $HOME/wallpapers
set -gx DOCUMENTS $HOME/Documents
set -gx PAGER bat
set -gx NNN_PLUG 'f:finder;o:fzopen;p:preview-tui;d:diffs;t:nmount;v:imgview;g:!git log;'
set -gx NNN_FIFO '/tmp/nnn.fifo'
set -gx NIX 'creator54@129.154.36.185'
set -gx phoenix 'creator54@152.67.165.253'
set -gx server_key '~/.ssh/id_webserver'

set -gx ANDROID_HOME /home/creator54/Android/Sdk/

fish_add_path -g $HOME/.node_modules/bin

if not test -d "$HOME/.npm-global/"
    npm config set prefix ~/.npm-global
end

fish_add_path -g $HOME/.npm-global/bin/
fish_add_path -g $HOME/.local/bin/
fish_add_path -g $HOME/.bun/bin
fish_add_path -g $HOME/.config/rofi/bin

# Add the .venv/bin directory to the $PATH
set -gx PATH $HOME/.venv/bin $PATH

# Set the LD_LIBRARY_PATH
set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH $HOME/.nix-profile/lib

if not test -d "$HOME/.venv"
    python -m venv "$HOME/.venv"
end

set VIRTUAL_ENV "$HOME/.venv"


direnv hook fish | source
starship init fish | source

# Needed for ssh verifiaction GIthub
if not pgrep ssh-agent &>/dev/null
    eval (ssh-agent -c) &>/dev/null
    for x in (ls /home/creator54/.ssh/ | grep -v ".pub\|known_hosts")
        ssh-add ~/.ssh/$x &>/dev/null
    end
end

if which vim &>/dev/null
    set -gx EDITOR vim
    set -gx VISUAL vim
else
    set -gx EDITOR nvim
    set -gx VISUAL nvim
end

if [ -f ~/api-chat ]
    set -gx OPENAI_API_KEY (sed 's/\n//g' ~/api-chat)
end

alias e $EDITOR
alias vim nvim
alias recent 'v -r'
alias chrome "google-chrome-stable --remote-debugging-port=9222 --user-data-dir=~/chromeData/ --remote-allow-origins=http://localhost:9222"


alias r "nix-env --uninstall"
alias q "nix-env -q"
alias n "which nvidia-offload&> /dev/null && nvidia-offload; or nnn"
alias d "cd ~/dev"
alias x "rm -rf $argv"
alias l 'v (ls | fzf )'
alias h "history | fzf | clip;echo copied to clipboard" #fish doesnt have process substitution yet

#some git alias
alias gi 'git init;git branch -M main'
alias gb 'git branch'
alias gl 'git log'
alias gd 'git diff'
alias gs 'git status'
alias gn 'git branch -M main'
alias gck 'git checkout'
alias gpull "git stash;git pull origin (gb | grep -e '*' | cut -d ' ' -f2);git stash pop"

alias hs hm
alias files nautilus
alias size gdu
alias calc eva
alias man batman
alias share serve
alias ftp ncftp
alias usage baobab
alias poweshell pash
alias gallery gthumb
alias pdfviewer okular
alias sys "cd /etc/nixos"
alias clip "xclip -sel clip"
alias apps "~/Apps-data/apps"
alias he "cmd home-manager edit"
alias usb "cd /run/media/$USER/"
alias clipboard "copyq clipboard"
alias view_pic "kitty +kitten icat" #for viewing images in kitty
alias fix-headphones "alsactl restore" #https://github.com/NixOS/nixpkgs/issues/34460
alias torrent "io.webtorrent.WebTorrent"
alias copy "rsync --info=progress2 -auvz"
alias phone "ftp ftp://192.168.1.236:2221"
alias keys "screenkey --no-systray -t 0.4"
alias headset "bluetooth on && sleep 1 && bluetoothctl connect (btid)"
alias btid "bluetoothctl devices | cut -d ' '  -f2"
alias lectures "cd /run/mount/data1/Lectures/Study"
alias stream "cvlc --fullscreen --aspect-ratio 16:9 --loop"
alias check "cmd nix-shell -I nixpkgs=/home/$USER/nixpkgs -p"
alias servers "echo $NIX\n$phoenix | dmenu -p ' Select server : '"
alias whereami "curl -s https://ipinfo.io/(curl -s https://ipinfo.io/ip)"
alias fget "wget -r –level=0 -E –ignore-length -x -k -p -erobots=off -np -N"
alias fzfv "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
alias dwmkeys "cat ~/dwm/config.def.h | sed -e '/^[ \t]*\/\//d' -e '/^[ \t]*\/\*/d' -e '/static/d' -e '/TAGKEYS/d' -e 's/{//' -e 's/},//'| grep -e XK -e Button | fzf"
alias xmr "xmrig -o pool.minexmr.com:4444 -k --coin monero -a rx/0 --randomx-mode=fast -u 47yKDNQ3bcggyHwp2GrTCV9QdMEP8VzqQak1h9fyvhhRCzfQXdkdonrdUVA4h2SP1QLQX68qmVKKjjDYweng1TAL1gKGS2m"
alias hxmr "xmrig -o pool.hashvault.pro:80 -k --coin monero -a rx/0 --randomx-mode=fast -u 47yKDNQ3bcggyHwp2GrTCV9QdMEP8VzqQak1h9fyvhhRCzfQXdkdonrdUVA4h2SP1QLQX68qmVKKjjDYweng1TAL1gKGS2m"
alias doge "xmrig -o rx.unmineable.com:3333 -a rx -k -u DOGE:DHzDUHACdrc5j6SM6bSsaWsvrPimFKg8Er.DOGEE#vejs-jzsz"

#for stuff inside this dir
set dir '~/.config/fish/scripts'

for i in (ls /home/$USER/.config/fish/scripts/)
    set script_name (echo $i |sed 's/.sh//')
    alias $script_name "$dir/$i"
end
