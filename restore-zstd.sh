#!/bin/bash

rm -rf tmp || true
mkdir tmp || true

start=$(date +%s)
rclone cat cache:fast-cache/$(date +%Y-%m-%d).tar.zstd |
  zstd -d - |
  tar -xf - -C tmp/
end=$(date +%s)
runtime=$((end - start))
echo "Restore: $runtime seconds"
