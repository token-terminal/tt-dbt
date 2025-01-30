# tt-dbt

Single binary DBT wrapper with Token Terminal configurations.

## Install

### macOS

1. Download the appropriate binary for your system from GitHub releases:
   - For Apple Silicon (M1/M2): `tt-dbt-darwin-arm64.gz`
   - For Intel Macs: `tt-dbt-darwin-x64.gz`

2. Extract the binary:
   ```bash
   gzip -d tt-dbt-darwin-*.gz
   ```

3. Make it executable:
   ```bash
   chmod +x tt-dbt-darwin-*
   ```

4. Move to a location in your PATH:
   ```bash
   sudo mv tt-dbt-darwin-* /usr/local/bin/tt-dbt
   ```

5. Verify installation:
   ```bash
   tt-dbt test-installation
   ```

### Linux

1. Download the appropriate binary for your system:
   - For x64 systems: `tt-dbt-linux-x64.gz`
   - For ARM64 systems: `tt-dbt-linux-arm64.gz`

2. Extract and install:
   ```bash
   gzip -d tt-dbt-linux-*.gz
   chmod +x tt-dbt-linux-*
   sudo mv tt-dbt-linux-* /usr/local/bin/tt-dbt
   ```

3. Verify installation:
   ```bash
   tt-dbt test-installation
   ```

## Usage

Run DBT commands normally:

```bash
# Run normal DBT commands
tt-dbt ls -m model_name
tt-dbt run -m tag:temp_tag

tt-dbt sqlfluff lint path/to/model

# Print help usage help
tt-dbt help
```

## Building from Source

The binary is built using Node.js and pkg.

1. Install Node.js 18 or later

2. Install dependencies:
   ```bash
   npm install
   ```

3. Build for all platforms:
   ```bash
   ./build.sh
   ```

   This will create binaries for:
   - Linux (x64, arm64)
   - macOS (x64, arm64)

   The binaries will be in the `releases` directory.

4. For development builds, you can also run directly with Node.js:
   ```bash
   node index.ts
   ```

## Security

The macOS binaries are signed with our Developer ID certificate and notarized by Apple, ensuring they can be run without security warnings. If you build from source, you may need to remove the quarantine attribute:

```bash
xattr -d com.apple.quarantine /usr/local/bin/tt-dbt
```

## Automatic releases

Releasing binaries can be done by pushing version tag to repo.

```
git tag -a v0.1.0 -m "Initial release"
git push origin v0.1.0
```

Releasing new version of docker runtime.

```
git tag -a docker/v1.0.0 -m "Initial DBT runtime docker release"
git push origin docker/v1.0.0
```

## Manual release

Example releasing `v0.1.0`.

```bash
./build.sh && gh release create v0.1.0 --title="tt-dbt 0.1.0" --generate-notes ./releases/*.gz
