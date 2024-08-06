function gx
    if contains -- $argv -h --help
        echo "Usage: gx [file/commitID]"
        echo "  -h, --help     Show this help message"
    else
        set target (count $argv) >/dev/null; and set target $argv[1]
        switch (count $argv)
            case 0
                git reset --hard
            case 1
                if test -f $target
                    git restore $target
                else
                    git reset --hard $target
                end
            case '*'
                for file in $argv
                    git restore $file
                end
        end
    end
end
