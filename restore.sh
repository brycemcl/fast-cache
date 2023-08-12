#!/bin/bash

rm -rf tmp || true
mkdir tmp || true

start=$(date +%s)
curl -s -L --request GET --url http://localhost:3000/ | lz4 -dc - | tar -xf - -C tmp/
end=$(date +%s)
runtime=$((end - start))
echo "Restore: $runtime seconds"
