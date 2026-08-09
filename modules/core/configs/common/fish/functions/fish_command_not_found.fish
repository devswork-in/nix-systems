function fish_command_not_found
    set -l first (string lower -- $argv[1])

    if test (count $argv) -ge 3
        switch $first
            case how what why can could would should explain fix debug help show write create make find list tell summarize compare check
                ? $argv
                return $status
        end
    end

    set -l exit_string "You know what you are doing, right ?" "Are you sure about that ?" "Sorry can't find what you are looking for :(" "IDK what you mean !" "Invalid command !" "You in the right mood mate ?"
    set -l index (random 1 6)
    printf '%s\n' $exit_string[$index]
    return 127
end
