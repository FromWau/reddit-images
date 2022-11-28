#!/bin/bash

MINSIZE=2000
LIMIT=300


for SUBREDDIT in $@
do

    # Check if SUBREDDIT exists
    sub_exits=$(curl -sH "User-agent: 'Bot'" https://www.reddit.com/r/$SUBREDDIT.json\?limit=1 | \
        jq > /dev/null 2>&1; echo "$?")

    [[ ! "$sub_exits" -eq "0" ]] &&
        echo "unknown subreddit $SUBREDDIT" &&
        continue
    
    # Create reddit dir if not exists
    [[ ! -d ~/Pictures/wallpapers/reddits/$SUBREDDIT ]] && 
        mkdir -p ~/Pictures/wallpapers/reddits/$SUBREDDIT

    # curl the data
    data=$(curl -H "User-agent: 'Bot'" https://www.reddit.com/r/"$SUBREDDIT".json\?limit=$LIMIT | \
        jq -r ".data.children" | jq -r ".[] | @base64")


    for item in $data
    do

        # needed for json array to bash array
        _jq() {
            echo "${item}" | base64 --decode | jq -r "${1}"
        }

        url=$(_jq '.data.url_overridden_by_dest')
        
        case $url in
            
            *".png" | *".jpg")
                source_width=$(_jq ".data.preview.images" | jq ".[0].source.width")
                source_height=$(_jq ".data.preview.images" | jq ".[0].source.height")
                
                if [[ "$MINSIZE" -gt "$source_height" || "$MINSIZE" -gt "$source_width" ]]
                then
                    echo "Ignoring $url to low res [ $source_width x $source_height ]"
                    continue 
                fi

                echo "Downloading $url [ $source_width x $source_height ]"
                curl -O "$url" --output-dir ~/Pictures/wallpapers/reddits/$SUBREDDIT
                ;;

            *)
                echo "Ignoring $url unknown format"
                ;;
        esac

    done

    feh --no-fehbg --recursive --randomize --bg-max ~/Pictures/wallpapers/reddits
done



