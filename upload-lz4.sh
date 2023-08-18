#!/bin/bash

start=$(date +%s)
tar -c ./node_modules/uploads/ |
  lz4 -z - |
  rclone rcat cache:fast-cache/$(date +%Y-%m-%d).tar.lz4
end=$(date +%s)
runtime=$((end - start))
echo "Upload: $runtime seconds"
