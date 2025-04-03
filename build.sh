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
  arch_dir="${BIN_DIR}/tt-dbt-${platform}"
  mkdir -p "$arch_dir"
  env -i "$BUN_BIN" build ./index.ts --minify --compile --sourcemap --target=bun-"$platform" --outfile "$arch_dir/tt-dbt"
  echo "Done building binary at $arch_dir/tt-dbt"
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
