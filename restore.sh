#!/bin/bash

rm -rf tmp || true
mkdir tmp || true

start=$(date +%s)
rclone cat cache:fast-cache/$(date +%Y-%m-%d).tar.zstd |
  mbuffer -s 1K -m 512M |
  zstd -d - |
  mbuffer -s 1K -m 512M |
  tar -xf - -C tmp/
end=$(date +%s)
runtime=$((end - start))
echo "Restore: $runtime seconds"
