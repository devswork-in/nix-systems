function __fish_command_not_found_handler --on-event fish_command_not_found
    #set -l exit_string "You know what you are doing, right ?" "Are you sure about that ?" "Sorry can't find what you are looking for :(" "IDK what you mean !" "Invalid command !" "You in the right mood mate ?"
    #set index (random 1 6)
    #printf '%s\n' $exit_string[$index]
    sgpt (echo "$argv" | sed 's/?/\\?/g')
end
