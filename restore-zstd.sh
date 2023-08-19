#!/bin/bash
set -e
rm -rf tmp || true
mkdir tmp || true

start=$(date +%s)
rclone cat \
  --fast-list \
  --ignore-checksum \
  --streaming-upload-cutoff=5Gi \
  --use-mmap \
  "cache:fast-cache/$CIRCLE_JOB-$CIRCLE_BUILD_NUM-$CIRCLE_NODE_INDEX.tar.zstdmt" |
  zstdmt -d - |
  tar -xf - -C tmp/
end=$(date +%s)
runtime=$((end - start))
echo "Restore: $runtime seconds"
