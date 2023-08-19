#!/bin/bash
set -e
rm -rf tmp || true
mkdir tmp || true

start=$(date +%s)
rclone cat \
  --buffer-size=16Mi \
  --checkers=16 \
  --fast-list \
  --ignore-checksum \
  --streaming-upload-cutoff=100Ki \
  --transfers=40 \
  --use-mmap \
  "cache:fast-cache/$CIRCLE_JOB-$CIRCLE_BUILD_NUM-$CIRCLE_NODE_INDEX-$SPEED-$LONG-$THEADS.tar.zstdmt" |
  zstdmt -d - |
  tar -xf - -C tmp/
end=$(date +%s)
runtime=$((end - start))
echo "Restore: $runtime seconds"
