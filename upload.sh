#!/bin/bash

start=$(date +%s)
tar --use-compress-program=lz4 -cf - ./node_modules/uploads/ | curl --request POST \
  --url http://localhost:3000/ \
  --header 'Content-Type: multipart/form-data' \
  --form file=@-
end=$(date +%s)
runtime=$((end - start))
echo "Upload: $runtime seconds"
