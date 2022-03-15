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

timers=("step" "tree" "balance" "density" "density local" "density remote" "force" "force local" "force remote" "extf")
for timer in "${timers[@]}"; do

function get_data(){
  local nodes=$1
  local ntasks_per_node=$2
  local cpus_pertask=$3
  local ntasks=$((ntasks_per_node*nodes))

  local d="run-${nodes}x${ntasks_per_node}x${cpus_pertask}"
  local f="$d/polar01.log"

  local line ttemp timing timer_a timber_b traw

  if [[ $timer = *" "* ]]; then
    timer_a=$(echo $timer | cut -d ' ' -f 1)
    timer_b=$(echo $timer | cut -d ' ' -f 2)
    line=$(sed -n "/─${timer_a}/,/─${timer_b}/p" $f | tail -1)
  else
    line=$(sed -n "/─${timer}/p" $f)
  fi

  line=$(echo $line | grep '%' | grep ':' | tr -s ' ' | cut -d ':' -f 2)

  timing="NaN"
  if [[ $get_percentage == 1 ]]; then
    traw=$(echo $line | cut -d ' ' -f 4)
    if [[ ! -z $traw ]]; then
      timing=$(echo $traw | cut -d '%' -f 1)
    fi
  else
    # Convert minutes to seconds
    traw=$(echo $line | cut -d ' ' -f 1)
    if [[ ! -z $traw ]]; then
      if [[ $traw == *min ]]; then
        ttemp=$(echo $traw | cut -d 'm' -f 1)
        timing=$(echo "print ${ttemp}*60" | perl)
      elif [[ $traw == *s ]]; then
        timing=$(echo $traw | cut -d 's' -f 1)
      fi
    fi
  fi

  # Print result
  echo $nodes $ntasks_per_node $cpus_per_task $timing
}

  loop get_data | column -t | tac > "timings_$(echo ${timer} | tr ' ' '_')${ext}.txt"

done
