#!/bin/bash

FILE=/home/agcgn/Masaüstü/aur-upgrade-incomplete
if test -f "$FILE"; then
    rm /home/agcgn/Masaüstü/aur-upgrade-incomplete
    echo "why the fuck is this so difficult fuck fuck fuck fuck fuck fuck fuck fuck fuck"

    #TODO how to run as root tho ?
    output=$(sudo pamac upgrade --no-confirm -a)
    echo $output > reportAur.txt

    #konsole -e /bin/bash --rcfile <(echo "echo 'pamac upgrade -a'")
fi



