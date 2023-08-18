#!/bin/bash

start=$(date +%s)
tar -c ./node_modules/uploads/ |
  mbuffer -s 1K -m 512M |
  zstd --fast=5 - |
  mbuffer -s 1K -m 512M |
  rclone rcat cache:fast-cache/$(date +%Y-%m-%d).tar.zstd
end=$(date +%s)
runtime=$((end - start))
echo "Upload: $runtime seconds"
