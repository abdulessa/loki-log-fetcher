FROM debian:latest

ARG LOGCLI_VERSION

RUN apt-get update && apt-get install -y curl zip less vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
# get logcli
RUN curl -L -o logcli_${LOGCLI_VERSION}_amd64.deb https://github.com/grafana/loki/releases/download/v${LOGCLI_VERSION}/logcli_${LOGCLI_VERSION}_amd64.deb && \
    apt-get install -y ./logcli_${LOGCLI_VERSION}_amd64.deb 

RUN mkdir -p /app/logs

COPY fetch_logs.sh /app/fetch_logs.sh

RUN chmod +x /app/fetch_logs.sh

WORKDIR /app

ENTRYPOINT ["bash", "/app/fetch_logs.sh"]