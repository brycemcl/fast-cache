#!/bin/bash
set -e
start=$(date +%s)
tar -c ./node_modules/uploads/ |
  lz4 -z - |
  rclone rcat \
    --fast-list \
    --ignore-checksum \
    --streaming-upload-cutoff=5Gi \
    --use-mmap \
    "cache:fast-cache/$CIRCLE_JOB-$CIRCLE_BUILD_NUM-$CIRCLE_NODE_INDEX.tar.lz4"
end=$(date +%s)
runtime=$((end - start))
echo "Upload: $runtime seconds"
