#!/bin/bash

# look for logcli
if ! command -v logcli &> /dev/null
then
    echo "logcli could not be found. Please ensure it is installed."
    exit 1
fi

# Loki credentials
: "${LOKI_USERNAME?Loki username must be provided}"
: "${LOKI_PASSWORD?Loki password must be provided}"
: "${LOKI_URL?Loki URL must be provided}"


# Define log query
query=${QUERY:-'{cluster="myCluster", job="myJob"}'}


# time range and interval
start_time=${START_TIME:-"2024-05-28T00:00:00Z"}
end_time=${END_TIME:-"2024-05-29T11:59:59Z"}
interval_days=${INTERVAL_DAYS:-1}
line_limit=${LINE_LIMIT:-900000}
extract_name=${EXTRACT_NAME:-"log-extract"}
output_dir=${OUTPUT_DIR:-"/app/logs"}


# add days to a date
add_days() {
    date -u -d "$1 + $2 days" +"%Y-%m-%dT%H:%M:%SZ"
}


fetch_logs() {
    local from=$1
    local to=$2
    local output_file=$3

    echo "Querying from ${from} to ${to} and saving to ${output_file}..."
    logcli query --timezone=UTC --from="${from}" --to="${to}" --addr="${LOKI_URL}" "${query}" --limit="${line_limit}" > "${output_file}"
    
    if [ $? -ne 0 ]; then
        echo "An error occurred while querying from ${from} to ${to}."
    fi
}


current_start_time=${start_time}

# check if the time range is 2 days or less
if [[ $(($(date -u -d "${end_time}" +%s) - $(date -u -d "${start_time}" +%s))) -le $((2 * 24 * 60 * 60)) ]]; then
    output_file="/app/logs/output_${start_time}_to_${end_time}.log"
    fetch_logs "${start_time}" "${end_time}" "${output_file}"
else
    while [[ $(date -u -d "${current_start_time}" +%s) -lt $(date -u -d "${end_time}" +%s) ]]; do
        current_end_time=$(add_days "${current_start_time}" "${interval_days}")
        if [[ $(date -u -d "${current_end_time}" +%s) -gt $(date -u -d "${end_time}" +%s) ]]; then
            current_end_time=${end_time}
        fi

        output_file="/app/logs/output_${current_start_time}_to_${current_end_time}.log"
        fetch_logs "${current_start_time}" "${current_end_time}" "${output_file}"

        current_start_time=$(add_days "${current_start_time}" "${interval_days}")
    done
fi    


# create a zip archive logs
timestamp=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
zip_extract="${output_dir}/${extract_name}_${timestamp}.zip"

# Zip the logs directory
zip -r ${zip_extract} ${output_dir}/*

echo "Logs have been extracted and zipped to ${zip_extract}"

echo "Completed query."
