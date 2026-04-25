function gpush
    if [ -z "$argv" ]
        git push origin (gb | grep -e '*' | cut -d ' ' -f2) --force
    else
        git push origin $argv
    end
end
