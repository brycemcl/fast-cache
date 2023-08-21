#!/bin/bash
set -e
set -o pipefail

start=$(date +%s)
CIRCLE_JOB=${CIRCLE_JOB:-"NA"}
CIRCLE_BUILD_NUM=${CIRCLE_BUILD_NUM:-"NA"}
CIRCLE_NODE_INDEX=${CIRCLE_NODE_INDEX:-"NA"}
SPEED=${SPEED:-"-3"}
LONG=${LONG:-"--long"}
THEADS=${THEADS:-"--threads=1"}
NUM_PIPES=${NUM_PIPES:-4}
BUFFER_SIZE=${BUFFER_SIZE:-"16Mi"}

# Cleanup function
cleanup() {
  # Kill the persistent writers and wait for all background jobs
  pkill -P $$ tail
  wait

  # Remove named pipes
  rm -f pipe*
}

# Register trap for cleanup
trap cleanup EXIT

# Create named pipes
for i in $(seq 1 $NUM_PIPES); do
  mkfifo "pipe$i"
done

# Start readers from named pipes
for i in $(seq 1 $NUM_PIPES); do
  tar -c -T "pipe$i" |
    zstd $SPEED $LONG $THEADS - |
    rclone rcat \
      --buffer-size=$BUFFER_SIZE \
      --checkers=16 \
      --fast-list \
      --ignore-checksum \
      --streaming-upload-cutoff=100Ki \
      --transfers=40 \
      --use-mmap \
      "cache:fast-cache/$CIRCLE_JOB-$CIRCLE_BUILD_NUM-$CIRCLE_NODE_INDEX-$SPEED-$LONG-$THEADS-$NUM_PIPES-$BUFFER_SIZE/$i.tar.zstdmt" &
done

# Start persistent writers for each pipe
for i in $(seq 1 $NUM_PIPES); do
  (tail -f /dev/null >"pipe$i") &
done

# Write find output to named pipes round-robin using a loop and print0
index=1
find ./node_modules/ -type f -print0 | while IFS= read -r -d $'\0' file; do
  echo "$file" >"pipe$index"
  ((index++))
  if [ $index -gt $NUM_PIPES ]; then
    index=1
  fi
done

end=$(date +%s)
runtime=$((end - start))
echo "Upload: $runtime seconds"
