#!/bin/bash
KEY=$1
PATHS=$2
set -e
start=$(date +%s)
tar -cP $PATHS |
  zstd -2 --long --threads=4 - |
  rclone rcat \
    --buffer-size=16Mi \
    --checkers=16 \
    --fast-list \
    --ignore-checksum \
    --streaming-upload-cutoff=100Ki \
    --transfers=40 \
    --use-mmap \
    "cache:fast-cache/$KEY.tar.zstd"
end=$(date +%s)
runtime=$((end - start))
echo "Upload: $runtime seconds"
echo "cache:fast-cache/$KEY.tar.zstd"
