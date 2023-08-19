#!/bin/bash

rm -rf tmp || true
mkdir tmp || true

start=$(date +%s)
rclone cat \
  --buffer-size=16Mi \
  --checkers=16 \
  --fast-list \
  --ignore-checksum \
  --multi-thread-cutoff=250Mi \
  --multi-thread-streams=20 \
  --streaming-upload-cutoff=100Ki \
  --transfers=40 \
  --use-mmap
cache:fast-cache/$(date +%Y-%m-%d).tar.zstdmt |
  mbuffer -s 1M -m 512M |
  zstdmt -d - |
  mbuffer -s 1M -m 512M |
  tar -xf - -C tmp/
end=$(date +%s)
runtime=$((end - start))
echo "Restore: $runtime seconds"
