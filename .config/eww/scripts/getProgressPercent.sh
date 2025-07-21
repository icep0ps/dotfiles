#!/usr/bin/env bash

current_time=$(playerctl metadata --player=spotify_player --format '{{duration(position)}}' | sed -r 's/[:]+//g')
duration=$(playerctl metadata --player=spotify_player --format '{{duration(mpris:length)}}' | sed -r 's/[:]+//g')

echo $(awk -v x=$current_time -v y=$duration 'BEGIN {printf ("%06.2f\n",x/y * 100) }')
exit 0
