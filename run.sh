#!/usr/bin/env bash

set -e

echo
echo "Starting Interactive Session"
echo

files=( ./src/*.rb )

PS3='Select file to run, or 0 to exit: '
select file in "${files[@]}"; do
    if [[ $REPLY == "0" ]]; then
        echo 'Bye!' >&2
        exit
    elif [[ -z $file ]]; then
        echo 'Invalid choice, try again' >&2
    else
        irb -r $file
        break
    fi
done
