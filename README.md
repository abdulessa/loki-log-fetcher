# Loki Log Fetcher

A script to automate log extraction from Grafana Loki via [logcli](https://grafana.com/docs/loki/latest/query/logcli/). Queries are made over a specified time range, breaking down the queries into intervals if necessary, and then compressing the resulting log files into a compressed archive. It is packaged with a Docker container for easy deployment.

## Requirements

- Docker
- Grafana Loki instance with access credentials

## Environment Variables

The following environment variables must be set before running the script:

- `LOKI_USERNAME`: Loki username.
- `LOKI_PASSWORD`: Loki password.
- `LOKI_URL`: Loki URL.

The following environment variables can be set to customize the script's behavior:

- `QUERY`: custom log query to execute.
- `START_TIME`: Start time for the log query in ISO 8601 format.
- `END_TIME`: End time for the log query in ISO 8601 format.
- `INTERVAL_DAYS`: Number of days per query interval.
- `LINE_LIMIT`: Maximum number of log lines per query.
- `EXTRACT_NAME`: Base name for the zip file containing the logs.

## Running the Script

1. **Build the Docker Image:**

   ```bash
   docker build --build-arg LOGCLI_VERSION=<desired-logcli-version> -t loki-log-fetcher .


2. **Run the Docker Container:**

  ```bash
  docker run --rm \
    -e LOKI_USERNAME="your_username" \
    -e LOKI_PASSWORD="your_password" \
    -e LOKI_URL="https://loki.example.com" \
    -e START_TIME="2024-05-28T00:00:00Z" \
    -e END_TIME="2024-05-29T11:59:59Z" \
    -v /path/to/your/logs:/app/logs \
    loki-log-fetcher
