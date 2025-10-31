function fish_search_files
    # Use first argument if provided, otherwise get current command line content
    set -l search_term
    if test -n "$argv[1]"
        set search_term $argv[1]
    else
        set search_term (commandline)
    end

    # Clear command line if called from keybinding (not with direct argument)
    if test -z "$argv[1]"
        commandline -r ''
    end
    
    # Use dynamic fzf with ripgrep for both cases
    set -l results
    if test -n "$search_term"
        # With search term: use same approach as no-keyword but with initial query
        set results (echo "" | fzf --height=100% --reverse --exit-0 --disabled --query="$search_term" --bind "start:reload:rg --line-number --no-heading --color=never --smart-case {q} . 2>/dev/null || true" --bind "change:reload:rg --line-number --no-heading --color=never --smart-case {q} . 2>/dev/null || true" --header="Search file contents (started with: $search_term)" --delimiter : --preview "bat --color=always --highlight-line {2} {1}" --preview-window "+{2}/2")
    else
        # Without search term: start empty, search as you type
        set results (fzf --height=100% --reverse --exit-0 --disabled --bind "change:reload:rg --line-number --no-heading --color=never --smart-case {q} . 2>/dev/null || true" --header="Type to search file contents" --delimiter : --preview "bat --color=always --highlight-line {2} {1}" --preview-window "+{2}/2")
    end

    if test -n "$results"
        # Determine editor
        set -l editor $EDITOR
        if test -z "$editor"
            set editor $VISUAL
            if test -z "$editor"
                set editor vim
            end
        end
        
        # Check if result has line number (from content search) or is just a filename
        if string match -q "*:*:*" "$results"
            # Format: filename:line_number:content (from ripgrep search)
            set -l file (echo "$results" | cut -d: -f1)
            set -l line_number (echo "$results" | cut -d: -f2)
            
            if test -n "$file" -a -f "$file" -a -n "$line_number"
                # Open with line number
                if string match -q "*vim*" (basename "$editor") || string match -q "*nvim*" (basename "$editor")
                    eval $editor +$line_number "$file"
                else if string match -q "*emacs*" (basename "$editor")
                    eval $editor +$line_number "$file"
                else if string match -q "*code*" (basename "$editor") || string match -q "*code-insiders*" (basename "$editor")
                    eval $editor "$file:$line_number"
                else
                    eval $editor +$line_number "$file"
                end
            end
        else
            # Just a filename (from fd file listing)
            if test -f "$results"
                eval $editor "$results"
            end
        end
    end
end
