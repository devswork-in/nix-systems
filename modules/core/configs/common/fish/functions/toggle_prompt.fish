function toggle_prompt -d "Toggle between starship and custom fish prompts"
    # Check current mode
    if set -q PROMPT_MODE; and test "$PROMPT_MODE" = "starship"
        # Switch to custom prompts
        functions -e fish_prompt 2>/dev/null
        functions -e fish_right_prompt 2>/dev/null
        functions -e starship_transient_prompt_func 2>/dev/null
        functions -e starship_transient_rprompt_func 2>/dev/null
        
        # Source custom prompts from the config directory
        if test -f ~/.config/fish/functions/fish_prompt.fish
            source ~/.config/fish/functions/fish_prompt.fish
        end
        if test -f ~/.config/fish/functions/fish_right_prompt.fish
            source ~/.config/fish/functions/fish_right_prompt.fish
        end
        
        set -g PROMPT_MODE "custom"
    else
        # Switch to starship
        functions -e fish_prompt 2>/dev/null
        functions -e fish_right_prompt 2>/dev/null
        
        # Check if starship is available
        if command -v starship >/dev/null 2>&1
            eval (starship init fish)
            set -g PROMPT_MODE "starship"
        else
            echo "Error: starship not found in PATH"
            return 1
        end
    end
    commandline -f repaint
end
