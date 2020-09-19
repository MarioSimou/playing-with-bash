#!/bin/bash

# Author: Marios Simou
# Description: Basic bash utility that show a histogram of the disk usage of a directory
# e-g ./histogram /usr/local/go

set -e 

declare -r dir="$1"

[[ ! -d $dir ]] && printf "Error: Pass a valid directory\n" && exit 1

declare -i totalSize=$(du -s ${dir} | awk '{ print $1 }')

function drawLine {
    local n_lines=$1

    [[ $n_lines -eq 0 ]] && exit 0
    [[ ! $n_lines ]] && printf "Error: Cannot draw a line with an invalid percentage\n" >&2 && exit 1

    for ((i=0;i < $n_lines;i++)); do
        printf "-"
    done
}

function drawHistogram {
    local file=$1
    local percentage=$2

    [[ ! $file || ! $percentage ]] && echo "Error: Issue drawing histogram\n" >&2 && exit 1

    local n_lines=$( echo $percentage | awk -F '.' '{ print $1 }')
    local histogram=$(drawLine $n_lines)
  
    printf "%s\t%3.2f percent\t|%s\n" $file $percentage $histogram
}

while read -r size file; do 
    percentage=$(echo "(${size}/${totalSize}) * 100" | bc -l)
    drawHistogram $file $percentage
done < <(du -s ${dir}/*)

