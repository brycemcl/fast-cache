#!/bin/bash

rm -rf tmp || true
mkdir tmp || true

start=$(date +%s)
rclone cat \
  --buffer-size=16Mi \
  --checkers=16 \
  --fast-list \
  --ignore-checksum \
  --streaming-upload-cutoff=100Ki \
  --transfers=40 \
  --use-mmap
cache:fast-cache/$(date +%Y-%m-%d).tar.lz4 |
  mbuffer -s 1M -m 512M |
  lz4 -dc - |
  mbuffer -s 1M -m 512M |
  tar -xf - -C tmp/
end=$(date +%s)
runtime=$((end - start))
echo "Restore: $runtime seconds"
