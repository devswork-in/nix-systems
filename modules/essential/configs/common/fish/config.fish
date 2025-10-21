set -gx EDITOR vim
set -gx VISUAL vim
set -gx PAGER "bat"

# Source general aliases
source ~/.config/aliases 2>/dev/null

if status is-interactive
  and not set -q TMUX
  if tmux ls
    exec tmux attach
  else
    exec tmux
  end
end

function gpull
  git pull origin (git branch | sed 's/^* //') --force
end

function gpush
  if [ -z "$argv" ]
    git push origin (gb | grep -e '*' | cut -d ' ' -f2) --force
  else
    git push origin $argv
  end
end

function ga
  if [ -z "$argv" ]
    git add .
  else
    git add $argv
  end
end

direnv hook fish | source