#!/bin/bash

set -e 

store_name="db"
store_path="$PWD/$store_name"
arguments="$@"
command=""
values=()
i=0

if [[ ! -e $store_path ]]; then
    echo "" > $store_path
fi

for arg in ${arguments}; do
    if [[ i -eq 0 ]]; then
        command="$arg"
        ((i++))
        continue
    fi

    values=(${values[@]} $arg)
done

if [[ ! command ]]; then
    printf "Error: Command not found\n"
    exit 1
fi

if [[ ${#values[@]} -eq 0 ]]; then 
    printf "Error: Please provide some values for '%s'\n" $command
    exit 1
fi

function set {
    local key="$1"
    local value="$2"

    if [[ ! value ]]; then
        printf "Error: Provide a value for key '%s'\n" $key
        exit 1
    fi

    local match=$(grep -n $key $store_path)

    if [[ $match ]]; then 
        local token=$(echo $match | awk -F ':' '{ print $2 }')

        if $(sed -i '' "s/$token/$key=$value/" $store_path); then 
            printf "ok\n"
            exit 0
        else
            printf "Error: Failed to set key '%s'\n" $key 
            exit 1
        fi
    else
        printf "%s=%s" $key $value >> $store_path
    fi
}

function get {
    local key="$1"
    local key_line=$(grep -n $key $store_path | awk -F ':' '{ print $1 }')

    if [[ ! $key_line ]]; then
        printf "Error: Key '%s' not found\n" $key
        exit 1
    fi

    local value=$(sed -n ${key_line}p $store_path | awk -F '=' '{ print $2 }')

    printf "$value\n"
    exit 0
}  

function del {
    local key="$1"
    local key_line=$(grep -n $key $store_path | awk -F ':' '{ print $1 }')

    if [[ ! $key_line ]]; then
        printf "Error: Key '%s' not found\n" $key
        exit 1
    fi

    if $(sed -i '' "${key_line}d" $store_path); then
        printf "ok\n"
        exit 0
    else
        printf "Error: Failed to remove key '%s'\n" $key    
    fi
}

case $command in
    SET)
        set ${values[@]};;
    GET)
        get ${values[@]};;
    DEL)
        del ${values[@]};;
    *)
        printf "Error: Command is not supported\n"
        exit 1  
esac