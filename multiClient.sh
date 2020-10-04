#!/bin/bash

set -e

function postgresdb {
  psql $@
} 
function mongodb {
  mongo $@
}

command=$1
# check number of arguments - if none raise error
[[ ! $command ]] && printf "Error: Missing command\n" && exit 1

[[ ! $(type $command 2> /dev/null) ]] && printf "Error: Command is not available. Please install the binary\n" && exit 127

shift

case $command in  
  psql|pg|postgres)
    postgres $@;;
  mongo)
    mongo $@;;
  *)
    printf "Error: Command not found\n" && exit 127;;
esac

exit 0