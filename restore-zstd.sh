#!/bin/bash

find_objects_in_bucket() {
  # Loop through all arguments passed to the function
  for param in "$@"; do
    # Try to find an exact match by adding the .tar.zstd prefix
    exact_match=$(rclone lsjson --fast-list --files-only cache:fast-cache/${param}.tar.zstd | jq -e '.[].Path')

    # If an exact match is found
    if [ -n "$exact_match" ]; then
      echo "Exact match found: $exact_match"
      process_objects "$exact_match"
      return
    else
      # Else, find a prefix match sorted by ModTime
      prefix_match=$(rclone lsjson --fast-list --files-only cache:fast-cache/ --include "${param}*" | jq 'sort_by(.ModTime) | last | .Path')

      if [ -n "$prefix_match" ]; then
        echo "Prefix match found: $prefix_match"
        process_objects "$prefix_match"
        return
      else
        echo "No match found for $param"
      fi
    fi
  done
}

process_objects() {
  local object=$1
  echo "Processing $object"
  rclone cat \
    --buffer-size=16Mi \
    --checkers=16 \
    --fast-list \
    --ignore-checksum \
    --transfers=40 \
    --use-mmap \
    "cache:fast-cache/$object" |
    zstd -d - |
    tar -xP --skip-old-files
}

# Call the function with all script arguments
find_objects_in_bucket "$@"
