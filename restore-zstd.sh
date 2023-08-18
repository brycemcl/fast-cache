#!/bin/bash

rm -rf tmp || true
mkdir tmp || true

start=$(date +%s)
rclone cat --transfers=32 cache:fast-cache/$(date +%Y-%m-%d).tar.zstdmt |
  mbuffer -s 1M -m 512M |
  zstdmt -d - |
  mbuffer -s 1M -m 512M |
  tar -xf - -C tmp/
end=$(date +%s)
runtime=$((end - start))
echo "Restore: $runtime seconds"
