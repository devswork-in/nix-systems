function fish_greeting
  set -l msg "Welcome back !" "I am up !" "What are we going to do today !" "How may i help ?"
  set index (random 1 4)
  printf '\n%s\n\n' $msg[$index]
end