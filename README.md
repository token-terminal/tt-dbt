# tt-dbt

Single binary DBT docker wrapper with Token Terminal configurations.

## Install

The release assets are named `tt-dbt-<os>-<arch>-<version>.gz` but are gzipped
**tar archives** containing a single `./tt-dbt` file — extract with `tar`, not
`gzip -d` (the latter leaves you with a tar archive and `exec format error`).

1. Download the asset for your platform from [GitHub releases](https://github.com/token-terminal/tt-dbt/releases) and extract the binary:

   ```bash
   tar -xzf tt-dbt-linux-x64-vX.Y.Z.gz        # -> ./tt-dbt
   # or, in one go, straight into PATH:
   tar -xzOf tt-dbt-linux-x64-vX.Y.Z.gz ./tt-dbt | sudo tee /usr/local/bin/tt-dbt >/dev/null
   ```

   Or build the binary from source (below).

2. Add execution rights: `chmod +x tt-dbt` (or `sudo chmod +x /usr/local/bin/tt-dbt`).

3. Put it on your PATH, eg. `sudo mv tt-dbt /usr/local/bin/`.

4. Run `tt-dbt test-installation` (needs `gcloud` and `docker` — podman with the `podman-docker` shim works too).

5. You can now run DBT with Token Terminal configuration in any DBT folder.

Scripted latest-release install (Linux x64):

```bash
tag=$(curl -fsSL https://api.github.com/repos/token-terminal/tt-dbt/releases/latest | jq -r .tag_name)
curl -fsSL "https://github.com/token-terminal/tt-dbt/releases/download/$tag/tt-dbt-linux-x64-$tag.gz" \
  | tar -xzOf - ./tt-dbt | sudo tee /usr/local/bin/tt-dbt >/dev/null && sudo chmod +x /usr/local/bin/tt-dbt
```

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
