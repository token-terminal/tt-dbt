#!/bin/bash

set -euox pipefail

# Build using Bun cross-compiling to other platforms
TARGET_PLATFORMS=(linux-x64 linux-arm64 darwin-x64 darwin-arm64)
BIN_DIR=./bin
RELEASES_DIR=./releases
BUN_BIN=$(which bun)

mkdir -p $BIN_DIR
mkdir -p $RELEASES_DIR

for platform in "${TARGET_PLATFORMS[@]}"; do
  echo "Building for $platform"
  env -i "$BUN_BIN" build ./index.ts --minify --compile --sourcemap --target=bun-"$platform" --outfile "${BIN_DIR}/tt-dbt"
  
  # For macOS platforms, just copy the binary to releases without compression
  if [[ $platform == darwin* ]]; then
    cp "${BIN_DIR}/tt-dbt" "${RELEASES_DIR}/tt-dbt-${platform}"
    echo "Done building for $platform, binary at ${RELEASES_DIR}/tt-dbt-${platform}"
  else
    # For non-macOS platforms, compress as before
    gzip -9 -N -c "${BIN_DIR}/tt-dbt" > "${RELEASES_DIR}/tt-dbt-${platform}.gz"
    echo "Done building for $platform, release at ${RELEASES_DIR}/tt-dbt-${platform}.gz"
  fi
done

echo "Done building for all platforms"

# To decompress:
# gzip -d -N ./releases/tt-dbt-darwin-arm64.gz
#
# To make executable:
# chmod +x ./releases/tt-dbt
#
# Test
# ./releases/tt-dbt dbt:test
