#!/bin/bash
set -e

start=$(date +%s)
rclone cat \
  --buffer-size=16Mi \
  --checkers=16 \
  --fast-list \
  --ignore-checksum \
  --transfers=40 \
  --use-mmap \
  "cache:fast-cache/$CIRCLE_JOB-$CIRCLE_BUILD_NUM-$CIRCLE_NODE_INDEX-$SPEED-$LONG-$THEADS.tar.zstd" |
  zstd -d - |
  tar -xP --skip-old-files
end=$(date +%s)
runtime=$((end - start))
echo "Restore: $runtime seconds"
echo "cache:fast-cache/$CIRCLE_JOB-$CIRCLE_BUILD_NUM-$CIRCLE_NODE_INDEX-$SPEED-$LONG-$THEADS.tar.zstd"
