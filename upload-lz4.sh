#!/bin/bash
set -e
start=$(date +%s)
tar -c ./node_modules/ |
  lz4 -z - |
  rclone rcat \
    --buffer-size=16Mi \
    --checkers=16 \
    --fast-list \
    --ignore-checksum \
    --streaming-upload-cutoff=100Ki \
    --transfers=40 \
    --use-mmap \
    "cache:fast-cache/$CIRCLE_JOB-$CIRCLE_BUILD_NUM-$CIRCLE_NODE_INDEX.tar.lz4"
end=$(date +%s)
runtime=$((end - start))
echo "Upload: $runtime seconds"
