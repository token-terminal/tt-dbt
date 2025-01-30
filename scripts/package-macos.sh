#!/bin/bash

set -euo pipefail

# Check required environment variables
if [[ "${1:-}" == "--ci" ]]; then
    # CI mode - requires certificate setup
    if [[ -z "${APPLE_CERTIFICATE:-}" ]] || [[ -z "${APPLE_CERTIFICATE_PASSWORD:-}" ]]; then
        echo "Error: APPLE_CERTIFICATE and APPLE_CERTIFICATE_PASSWORD are required in CI mode"
        exit 1
    fi
fi

RELEASES_DIR="./releases"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function setup_keychain() {
    echo "Setting up keychain..."
    echo "$APPLE_CERTIFICATE" | base64 --decode > certificate.p12
    security create-keychain -p "" build.keychain
    security default-keychain -s build.keychain
    security unlock-keychain -p "" build.keychain
    security import certificate.p12 -k build.keychain -P "$APPLE_CERTIFICATE_PASSWORD" -T /usr/bin/codesign
    security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "" build.keychain
    rm certificate.p12
}

function prepare_binary() {
    local arch=$1
    echo "Preparing binary for $arch..."
    chmod +x "$RELEASES_DIR/tt-dbt-darwin-$arch"
}

function sign_binary() {
    local arch=$1
    echo "Signing binary for $arch..."
    
    codesign --force --options runtime --timestamp --strict \
        --sign "Developer ID Application" \
        "$RELEASES_DIR/tt-dbt-darwin-$arch"
}

function notarize_binary() {
    local arch=$1
    echo "Notarizing binary for $arch..."
    
    if [[ -z "${APPLE_ID:-}" ]] || [[ -z "${APPLE_TEAM_ID:-}" ]] || [[ -z "${APPLE_APP_SPECIFIC_PASSWORD:-}" ]]; then
        echo "Skipping notarization - required credentials not found"
        return
    fi
    
    # Create zip for notarization
    ditto -c -k --keepParent "$RELEASES_DIR/tt-dbt-darwin-$arch" \
        "$RELEASES_DIR/tt-dbt-darwin-$arch.zip"
    
    # Submit for notarization
    xcrun notarytool submit "$RELEASES_DIR/tt-dbt-darwin-$arch.zip" \
        --apple-id "$APPLE_ID" \
        --password "$APPLE_APP_SPECIFIC_PASSWORD" \
        --team-id "$APPLE_TEAM_ID" \
        --wait
    
    # Staple the notarization ticket
    xcrun stapler staple "$RELEASES_DIR/tt-dbt-darwin-$arch"
    
    # Clean up
    rm "$RELEASES_DIR/tt-dbt-darwin-$arch.zip"
}

function compress_binary() {
    local arch=$1
    echo "Compressing binary for $arch..."
    
    gzip -9 -N -c "$RELEASES_DIR/tt-dbt-darwin-$arch" > "$RELEASES_DIR/tt-dbt-darwin-$arch.gz"
}

# Main process
main() {
    if [[ "${1:-}" == "--ci" ]]; then
        setup_keychain
    fi
    
    for arch in arm64 x64; do
        prepare_binary "$arch"
        sign_binary "$arch"
        
        if [[ "${1:-}" == "--ci" ]]; then
            notarize_binary "$arch"
        fi
        
        compress_binary "$arch"
    done
}

# Run main function with all arguments
main "$@"
