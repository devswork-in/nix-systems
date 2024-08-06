#!/usr/bin/env bash

set -e -o pipefail

value=$(ifconfig "$1" | grep X.pa | xargs | sed 's/(//g;s/)//g')
up=$(echo "$value" | awk '{print $12}')
down=$(echo "$value" | awk '{print $5}')
up_unit=$(echo "$value" | awk '{print $14}')
down_unit=$(echo "$value" | awk '{print $7}')

case "$down_unit" in
  "KiB")
    down=$(bc <<< "scale=0; $down/1000")
    down_unit="KB"
    ;;
  "MiB")
    down=$(bc <<< "scale=2; $down/1000000")
    down_unit="MB"
    ;;
  "GiB")
    down=$(bc <<< "scale=3; $down/1000000000")
    down_unit="GB"
    ;;
esac

case "$up_unit" in
  "KiB")
    up=$(bc <<< "scale=0; $up/1000")
    up_unit="KB"
    ;;
  "MiB")
    up=$(bc <<< "scale=2; $up/1000000")
    up_unit="MB"
    ;;
  "GiB")
    up=$(bc <<< "scale=3; $up/1000000000")
    up_unit="GB"
    ;;
esac

printf " %s %s  %s %s\n" "$up" "$up_unit" "$down" "$down_unit"
