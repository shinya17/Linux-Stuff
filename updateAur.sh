#!/bin/bash

FILE=/home/agcgn/Masaüstü/aur-upgrade-incomplete
if test -f "$FILE"; then
    
    echo "why the fuck is this so difficult fuck fuck fuck fuck fuck fuck fuck fuck fuck"

    #TODO how to run as root tho ?
    output=$(sudo pamac upgrade --no-confirm -a)
    rm reportAur.txt
    echo $(date) >> reportAur.txt
    echo $output >> reportAur.txt
    rm /home/agcgn/Masaüstü/aur-upgrade-incomplete

    #konsole -e /bin/bash --rcfile <(echo "echo 'pamac upgrade -a'")
fi



