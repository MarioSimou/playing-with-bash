#!/bin/bash

set -e
set -f

function operation {
  local command=$1
  shift

  [[ ! $(echo ${command} | egrep -E -o "+|-|\/|\*") ]] && printf "Error: Please provide a command\n" && exit 1

  [[ $# -eq 0 ]] && printf "Error: Please provide a set of number\n" && exit 1

  local result=$1
  shift

  for num in ${@}; do 
    result=$(( $result $command $num ))
  done

  printf "Result: %s\n" $result
}

command=$1

[[ ! $command ]] && printf "Error: Command not found" && exit 127

shift

case $command in 
  add)
    operation + $@;;
  substract)
    operation - $@;;
  multiply)
    operation * $@;;
  divide)
    operation / $@;;
  *)
    printf "Error: Command not found\n" && exit 127
esac

exit 0