function save
    set url_prefix "https://go.creator54.dev/"
    set gradle_dir /home/creator54/url_shortner/

    switch (count $argv)
        case 0, case 1
            echo "Usage: creates a shortened redirect of the shared URL"
            echo "save -a LONG_URL : creates a short redirect URL -> LONG_URL"
            echo "save -a CUSTOM_NAME LONG_URL : creates a short redirect URL -> LONG_URL"
            echo "save -r LONG_URL|CUSTOM_NAME : removes the redirect"
        case 2
            if [ "$argv[1]" = -r ]
                ssh -i ~/.ssh/id_webserver $phoenix "cd $gradle_dir; ./gradlew run -Pargs='remove,$argv[2]'" &>/dev/null
                [ $status ] && echo "Removed redirect: $argv[2]"
            else
                ssh -i ~/.ssh/id_webserver $phoenix "cd $gradle_dir; ./gradlew run -Pargs='add,$argv[2]'" &>/dev/null
            end
        case 3
            set custom_name $argv[2]
            set long_url $argv[3]
            if ssh -i ~/.ssh/id_webserver $phoenix "cd $gradle_dir; ./gradlew run -Pargs='save,$custom_name,$long_url'" &>/dev/null
                echo "Created redirect: $url_prefix$custom_name -> $long_url"
                echo $url_prefix$custom_name | clip
            else
                echo "Failed to create/connect!"
            end
        case '*'
            echo "Invalid usage: Too many arguments provided."
    end
end
