#!/usr/bin/env bash

get_percentage=0

while [[ "$1" == --* ]]; do
  case $1 in
    --percent)
      get_percentage=1;
      ;;

    *)
      badflag=$1
      ;;
  esac
  shift
done

if [[ "$badflag" != "" ]]; then
   echo "ERROR: Unknown flag $badflag"
   exit
fi

if [[ $get_percentage == 1 ]]; then
  ext='_%'
else
  ext=
fi

set -eu
source loop.sh

timers=("step" "tree" "balance" "density" "force" "extf")
for timer in "${timers[@]}"; do

function get_data(){
  local nodes=$1
  local ntasks_per_node=$2
  local cpus_pertask=$3
  local ntasks=$((ntasks_per_node*nodes))

  local d="run-${nodes}x${ntasks_per_node}x${cpus_pertask}"
  local f="$d/polar01.log"

  local ttemp tsec

  if [[ $get_percentage == 1 ]]; then
    local traw=$(grep "$timer" $f | grep '%' | grep ':' | tr -s ' ' | cut -d ':' -f 2 | cut -d ' ' -f 5)
    if [[ ! -z $traw ]]; then
      tsec=$(echo $traw | cut -d '%' -f 1)
    else
      tsec="NaN"
    fi
  else
    # Convert minutes to seconds
    local traw=$(grep "$timer" $f | grep '%' | grep ':' | tr -s ' ' | cut -d ':' -f 2 | cut -d ' ' -f 2)
    if [[ ! -z $traw ]]; then
      if [[ $traw == *min ]]; then
        ttemp=$(echo $traw | cut -d 'm' -f 1)
        tsec=$(echo "print ${ttemp}*60" | perl)
      elif [[ $traw == *s ]]; then
        tsec=$(echo $traw | cut -d 's' -f 1)
      fi
    else
      tsec="NaN"
    fi
  fi

  # Print result
  echo $nodes $ntasks_per_node $cpus_per_task $tsec
}

  loop get_data | column -t | tac > "timings_${timer}${ext}.txt"

done
