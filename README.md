# tt-dbt

Single binary DBT docker wrapper with Token Terminal configurations.

## Install

1. Download binary from github releases and extract (eg. `gzip -d -N ./path/to/downloaded/file`) or build binary from source.

2. Add execution rights for the binary `chmod +x /path/to/extracted/binary`.

3. Add binary to PATH eg. `sudo mv /path/to/extracted/binary /usr/local/bin`

4. Run `tt-dbt test-installation`

5. You can now run DBT with Token Terminal configuration in any DBT folder

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
```
