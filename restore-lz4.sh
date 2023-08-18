#!/bin/bash

rm -rf tmp || true
mkdir tmp || true

start=$(date +%s)
rclone cat --transfers=120 --checkers=120 --fast-list --multi-thread-streams=20 --multi-thread-cutoff=5M --ignore-checksum cache:fast-cache/$(date +%Y-%m-%d).tar.lz4mt |
  mbuffer -s 1M -m 512M |
  lz4mt -dc - |
  mbuffer -s 1M -m 512M |
  tar -xf - -C tmp/
end=$(date +%s)
runtime=$((end - start))
echo "Restore: $runtime seconds"
