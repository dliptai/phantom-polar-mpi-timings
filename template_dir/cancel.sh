#!/usr/bin/env bash

set -eu

for item in $(cat job.names); do
  scancel -n "$item"
done
