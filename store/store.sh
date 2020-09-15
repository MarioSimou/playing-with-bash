#!/bin/bash

# Author: Mario Simou
# Desc: A key-value storage written with shell scripting/bash 

#  store.sh -n db SET hello world
#  store.sh -n db GET hello
#  store.sh -n db DEL hello

set -e 

declare store_name="db"
declare store_dir="$PWD"

while getopts "n:" opt; do
    case $opt in
        n)
            store_name="$OPTARG";;
        \?)
            printf "Uknown option: ${OPTARG}" >&2 
            exit 1;;
    esac
done

# Ignores the indices for opts
shift $(( OPTIND -1 ))

declare -r store_path="${store_dir}/${store_name}"
declare -r command="$1"

[[ ! $command ]] && printf "Error: Command not found\n" >&2 && exit 1

# we ensure that user has passed at least one argument
shift

function ok {
    printf "ok\n"
    exit 0
} 

function set {
    declare -r key="$1"
    declare -r value="$2"

    [[ ! $key ]] && printf "Error: Please provide a valid key for SET command\n" >&2 && exit 1
    [[ ! $value ]] &&  printf "Error: Provide a value for key '%s'\n" $key && exit 1

    declare -r match=$(grep -n $key $store_path 2> /dev/null )

    if [[ $match ]]; then 
        declare -r old_pair=$(echo $match | awk -F ':' '{ print $2 }')

        if $(sed -i '' "s/$old_pair/$key=$value/" $store_path 2> /dev/null); then 
            ok
        else
            printf "Error: Failed to set key '%s'\n" $key 
            exit 1
        fi
    else
        if [[ -e $store_path ]]; then 
            printf "%s=%s\n" $key $value >> $store_path
        else 
            printf "%s=%s\n" $key $value > $store_path
        fi
        ok
    fi
}

function get {
    declare -r key="$1"
    
    [[ ! $key ]] && printf "Error: Please provide a valid key for GET command\n" >&2 && exit 1
    
    declare -r -i key_line=$(grep -n $key $store_path 2> /dev/null | awk -F ':' '{ print $1 }')
    
    if (( ! $key_line )); then 
        printf "Error: Key '%s' not found\n" $key && exit 1
    fi

    declare -r value=$(sed -n ${key_line}p $store_path | awk -F '=' '{ print $2 }')

    printf "$value\n"
    exit 0
}  

function del {
    declare -r key="$1"
    declare -r -i key_line=$(grep -n $key $store_path 2> /dev/null | awk -F ':' '{ print $1 }')

    if (( ! $key_line )); then 
        printf "Error: Key '%s' not found\n" $key && exit 1
    fi

    if $(sed -i '' "${key_line}d" $store_path); then
        ok
    else
        printf "Error: Failed to remove key '%s'\n" $key    
    fi
}

case $command in
    SET|set)   
        set $@;;
    GET|get)
        get $@;;
    DEL|del)
        del $@;;
    *)
        printf "Error: Command is not supported\n" >&2 && exit 1;;
esac