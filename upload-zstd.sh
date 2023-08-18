#!/bin/bash

start=$(date +%s)
tar -c ./node_modules/uploads/ |
  mbuffer -s 1M -m 512M |
  zstd --fast=5 - |
  mbuffer -s 1M -m 512M |
  rclone rcat --transfers=32 cache:fast-cache/$(date +%Y-%m-%d).tar.zstd
end=$(date +%s)
runtime=$((end - start))
echo "Upload: $runtime seconds"
