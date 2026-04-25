function gpull
    git pull origin (git branch | sed 's/^* //') --force
end
