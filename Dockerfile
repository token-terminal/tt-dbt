FROM ghcr.io/dbt-labs/dbt-bigquery:1.9.0

LABEL org.opencontainers.image.source=https://github.com/token-terminal/tt-dbt
LABEL org.opencontainers.image.description="Token Terminal DBT runtime"

RUN python -m pip install --upgrade "sqlfluff==3.3.0" "sqlfluff-templater-dbt==3.3.0" --no-cache-dir

RUN apt update && apt install gettext curl -y

RUN curl https://sdk.cloud.google.com | bash && \
    echo "source /root/google-cloud-sdk/path.bash.inc" >> ~/.bashrc && \
    echo "source /root/google-cloud-sdk/completion.bash.inc" >> ~/.bashrc && \
    touch ~/.bigqueryrc

COPY .sqlfluff /usr/app/.sqlfluff

ENTRYPOINT  []

CMD ["echo", "define command manually!!"]
