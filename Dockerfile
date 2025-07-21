# syntax=docker/dockerfile:1.6
ARG PY_VERSION=3.11.2

########################
# 1 ─── Builder stage ──
########################
FROM python:${PY_VERSION}-slim-bullseye AS builder

# Exclude docs/man at *build* time too (saves ≈70 MB)
RUN printf "path-exclude /usr/share/man/*\n\
path-exclude /usr/share/doc/*\n\
path-exclude /usr/share/doc-base/*\n" \
    > /etc/dpkg/dpkg.cfg.d/01_nodocs

# Build‑time system deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential git curl gettext

# Create and pre‑activate a dedicated venv
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

# Python tooling + DBT stack (no wheel cache, no .pyc)
RUN pip install --upgrade --no-cache-dir --no-compile \
        pip==24.0 setuptools==69.2.0 wheel==0.43.0 && \
    pip install --no-cache-dir --no-compile \
        dbt-bigquery==1.10.0 \
        sqlfluff==3.3.0 \
        sqlfluff-templater-dbt==3.3.0

# Remove tests, __pycache__, *.pyc from venv
RUN find /opt/venv \( -name tests -o -name '__pycache__' \
                      -o -name '*.py[co]' \) -prune -exec rm -rf '{}' +

########################
# 2 ─── Runtime stage ─
########################
FROM python:${PY_VERSION}-slim-bullseye AS runtime

# Keep the doc/man exclusion in the final image
RUN printf "path-exclude /usr/share/man/*\n\
path-exclude /usr/share/doc/*\n\
path-exclude /usr/share/doc-base/*\n" \
    > /etc/dpkg/dpkg.cfg.d/01_nodocs

ENV PATH="/opt/venv/bin:${PATH}" \
    PYTHONIOENCODING=utf-8 \
    LANG=C.UTF-8

# --- Minimal Google Cloud CLI (core + bq, no kubectl, no App Engine) ---
RUN set -e; \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz && \
    tar -xf google-cloud-cli-linux-x86_64.tar.gz && \
    rm google-cloud-cli-linux-x86_64.tar.gz && \
    /google-cloud-sdk/install.sh --quiet && \
    rm -rf /google-cloud-sdk  /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the prepared virtual‑env from the builder
COPY --from=builder /opt/venv /opt/venv

# Project files / configuration
WORKDIR /usr/app/dbt
COPY .sqlfluff /usr/app/.sqlfluff

# Health‑check & defaults
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s \
  CMD dbt --version || exit 1

ENTRYPOINT []
CMD ["echo", "define command manually!!"]
