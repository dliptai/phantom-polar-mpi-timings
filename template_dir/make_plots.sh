#!/usr/bin/env bash
set -eu

for item in $(echo timings_*.txt); do
  outfile=$(echo "$item" | sed 's/\.txt/\.pdf/g')
  ./analyse.py -o "$outfile" "$item"
done
