#!/bin/bash

set -euox pipefail

# Build using pkg to create native binaries
BIN_DIR=./bin
RELEASES_DIR=./releases

mkdir -p $BIN_DIR
mkdir -p $RELEASES_DIR

# Install pkg if not already installed
npm install -g pkg

# Build for all platforms
echo "Building binaries using pkg..."

# Build for different platforms
pkg ./index.ts \
  --targets node18-linux-x64,node18-linux-arm64,node18-macos-x64,node18-macos-arm64 \
  --output $BIN_DIR/tt-dbt

# Move and rename binaries to releases directory
mv "$BIN_DIR/tt-dbt-linux-x64" "$RELEASES_DIR/tt-dbt-linux-x64"
mv "$BIN_DIR/tt-dbt-linux-arm64" "$RELEASES_DIR/tt-dbt-linux-arm64"
mv "$BIN_DIR/tt-dbt-macos-x64" "$RELEASES_DIR/tt-dbt-darwin-x64"
mv "$BIN_DIR/tt-dbt-macos-arm64" "$RELEASES_DIR/tt-dbt-darwin-arm64"

# Compress Linux binaries
gzip -9 -N -c "$RELEASES_DIR/tt-dbt-linux-x64" > "$RELEASES_DIR/tt-dbt-linux-x64.gz"
gzip -9 -N -c "$RELEASES_DIR/tt-dbt-linux-arm64" > "$RELEASES_DIR/tt-dbt-linux-arm64.gz"

echo "Done building for all platforms"

# To decompress:
# gzip -d -N ./releases/tt-dbt-darwin-arm64.gz
#
# To make executable:
# chmod +x ./releases/tt-dbt
#
# Test
# ./releases/tt-dbt dbt:test
