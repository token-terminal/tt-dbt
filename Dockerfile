ARG py_version=3.11.2

FROM python:$py_version-slim-bullseye AS base

RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    build-essential=12.9 \
    ca-certificates=20210119 \
    git=1:2.30.2-1+deb11u2 \
    make=4.3-4.1 \
    openssh-client=1:8.4p1-5+deb11u3 \
    software-properties-common=0.96.20.2-2.1 \
  && apt-get clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

ENV PYTHONIOENCODING=utf-8
ENV LANG=C.UTF-8

RUN python -m pip install --upgrade "pip==24.0" "setuptools==69.2.0" "wheel==0.43.0" --no-cache-dir

FROM base AS dbt-bigquery

HEALTHCHECK CMD dbt --version || exit 1

WORKDIR /usr/app/dbt/

RUN python -m pip install --upgrade "sqlfluff==3.3.0" "sqlfluff-templater-dbt==3.3.0" --no-cache-dir
RUN python -m pip install dbt-bigquery==1.10.0


LABEL org.opencontainers.image.source=https://github.com/token-terminal/tt-dbt
LABEL org.opencontainers.image.description="Token Terminal DBT runtime"

RUN apt update && apt install gettext curl -y

RUN curl https://sdk.cloud.google.com | bash && \
    echo "source /root/google-cloud-sdk/path.bash.inc" >> ~/.bashrc && \
    echo "source /root/google-cloud-sdk/completion.bash.inc" >> ~/.bashrc && \
    touch ~/.bigqueryrc

COPY .sqlfluff /usr/app/.sqlfluff

ENTRYPOINT  []
RUN touch ~/.bigqueryrc
CMD ["echo", "define command manually!!"]


