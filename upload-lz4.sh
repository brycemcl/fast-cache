#!/bin/bash

start=$(date +%s)
tar -c ./node_modules/uploads/ |
  mbuffer -s 1M -m 512M |
  lz4 -z - |
  mbuffer -s 1M -m 512M |
  rclone rcat \
    --buffer-size=16Mi \
    --checkers=16 \
    --fast-list \
    --ignore-checksum \
    --streaming-upload-cutoff=100Ki \
    --transfers=40 \
    --use-mmap \
    cache:fast-cache/$(date +%Y-%m-%d).tar.lz4
end=$(date +%s)
runtime=$((end - start))
echo "Upload: $runtime seconds"
