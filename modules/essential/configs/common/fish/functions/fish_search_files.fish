function fish_search_files
    # Use first argument if provided, otherwise get current command line content
    set -l search_term
    if test -n "$argv[1]"
        set search_term $argv[1]
    else
        set search_term (commandline)
    end
    
    # If no search term, exit with message
    if test -z "$search_term"
        echo "Usage: Type search term and press Ctrl+s, or run 'fish_search_files <search_term>'"
        return 1
    end

    # If called directly with argument, don't clear command line (only clear when used as keybinding)
    if test -z "$argv[1]"
        commandline -r ''  # Clear the command line only when used from keybinding
    end
    
    # Use ripgrep to search for the text in files, excluding common binary files
    set -l results (rg -F --with-filename --line-number --no-heading --color=never "$search_term" . 2>/dev/null | head -1000 | fzf --height=100% --reverse --exit-0 --header="Select file to open (Search term: $search_term)")

    if test -n "$results"
        # Extract file and line number from the result (format: filename:line_number:content)
        set -l file (echo "$results" | cut -d: -f1)
        set -l line_number (echo "$results" | cut -d: -f2)
        if test -n "$file" -a -f "$file" -a -n "$line_number"
            # Use $EDITOR with line number support
            set -l editor $EDITOR
            if test -z "$editor"
                set -l editor $VISUAL
                if test -z "$editor"
                    set -l editor vim
                end
            end
            
            # Check if the editor supports line number option
            if string match -q "*vim*" (basename "$editor") || string match -q "*nvim*" (basename "$editor")
                eval $editor +$line_number "$file"
            else if string match -q "*emacs*" (basename "$editor")
                eval $editor +$line_number "$file"
            else if string match -q "*code*" (basename "$editor") || string match -q "*code-insiders*" (basename "$editor")
                eval $editor "$file:$line_number"
            else
                # Default fallback to vim format if editor type is unknown
                eval $editor +$line_number "$file"
            end
        else
            echo "Could not extract file or line number from selection"
        end
    end
end
