#!/bin/bash
set -e
set -o pipefail

start=$(date +%s)
: "${CIRCLE_JOB:=local}"
: "${CIRCLE_BUILD_NUM:=local}"
: "${CIRCLE_NODE_INDEX:=0}"

# Define the number of batches
NUM_BATCHES=4

upload_batch() {
  local pipe="$1"
  local batch_name="$2"

  while true; do
    if read -r file; then
      if [[ "$file" == 'EOF' ]]; then
        break
      fi
      echo "$file"
    fi
  done <"$pipe" |
    tar -c --files-from - |
    zstdmt --fast=5 - |
    rclone rcat \
      --buffer-size=16Mi \
      --checkers=16 \
      --fast-list \
      --ignore-checksum \
      --streaming-upload-cutoff=100Ki \
      --transfers=40 \
      --use-mmap \
      "cache:fast-cache/$CIRCLE_JOB-$CIRCLE_BUILD_NUM-$CIRCLE_NODE_INDEX/$batch_name.tar.zstdmt"
}

cleanup() {
  for i in $(seq 0 $((NUM_BATCHES - 1))); do
    rm -f "batch-$i.pipe" || true
  done
}

# Trap the cleanup function to be called on exit
trap cleanup EXIT

# Create a named pipe for each batch and spawn a handler
for i in $(seq 0 $((NUM_BATCHES - 1))); do
  mkfifo "batch-$i.pipe"
  upload_batch "batch-$i.pipe" "batch-$i" &
done

# Divide files into batches round-robin style
batch_number=0
find ./node_modules/uploads -type f | while read -r file; do
  batch=$(((batch_number) % NUM_BATCHES))
  echo "$file" >"batch-$batch.pipe"
  batch_number=$((batch_number + 1))
done

# # Send sentinel value to signal end of data
for i in $(seq 0 $((NUM_BATCHES - 1))); do
  echo "EOF" >"batch-$i.pipe"
done

# Wait for all background jobs to complete
wait

end=$(date +%s)
runtime=$((end - start))
echo "Upload: $runtime seconds"
