# tt-dbt

Single binary DBT docker wrapper with Token Terminal configurations.

## Install

1. Download binary from github releases and extract (eg. `gzip -d -N ./releases/tt-dbt-darwin-arm64.gz`) or build binary from source.

2. Add binary to PATH eg. `sudo mv ./tt-dbt /usr/local/bin`

3. Run `tt-dbt test-installation`

4. You can now run DBT with Token Terminal configuration in any DBT folder

## Usage

Run DBT commands normally

```bash
# Run normal DBT commands
tt-dbt ls -m model_name
tt-dbt run -m tag:temp_tag

tt-dbt sqlfluff lint path/to/model

# Print help usage help
tt-dbt help
```

## Building

Single binary is built using [Bun](https://bun.sh).

[Install Bun](https://bun.sh/docs/installation).

Install dependencies:

```bash
bun install
```

To build single platform:

```bash
bun build ./index.ts --minify --compile --sourcemap  --target=bun-darwin-arm64 --outfile ./bin/tt-dbt
```

To build all platforms:

```bash
./build.sh
```

## Manual release

Example releasing `v0.1.0`.

```bash
./build.sh && gh release create v0.1.0 --title="tt-dbt 0.1.0" --generate-notes ./releases/*.gz
```
