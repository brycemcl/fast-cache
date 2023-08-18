#!/bin/bash

start=$(date +%s)
tar -c - ./node_modules/uploads/ |
  zstd --fast=5 - |
  rclone rcat cache:fast-cache/$(date +%Y-%m-%d).tar.zstd
end=$(date +%s)
runtime=$((end - start))
echo "Upload: $runtime seconds"
