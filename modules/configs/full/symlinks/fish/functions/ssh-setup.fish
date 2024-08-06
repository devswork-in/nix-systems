function ssh-setup
    set ids_loc "/home/creator54/.ssh/id_rsa_"
    read -P "Email: " email
    set ids_loc {$ids_loc}(echo $email | cut -d'@' -f2 | cut -d'.' -f1) #pass ORG name as unique identifier. i.e string b/w '@' & '.' from mail-id
    echo $ids_loc | ssh-keygen -t rsa -b 4096 -C $email &>/dev/null
    eval (ssh-agent -c)
    ssh-add $ids_loc
    cat $ids_loc.pub | clip
    printf "Copied SSH public Key to Clipboard, now paste it on Github/Gitlab.\n"
    line
    echo
    read -P "Enter remote url to test SSH Connection(ex: git@gitlab.com/git@github.com): " url
    line
    echo
    ssh -i $ids_loc $url
end
