#!/usr/bin/env bash
set -e

# define environment
export HTTP_HOST=${HTTP_HOST:-"127.0.0.1:31007"}
export URL="http://${HTTP_HOST}/api/v1/ping"

function start_cnosdb() {
    rm -rf ./data
    if [ -e "./target/release/main" ];then
      nohup ./target/release/main run --cpu 4 --memory 8 --http-host ${HTTP_HOST} > /dev/null 2>&1&
    else
      nohup cargo run --release -- run --cpu 4 --memory 8 --http-host ${HTTP_HOST} > /dev/null 2>&1&
    fi
    echo $!
}

function wait_start() {
    while [ "$(curl -s ${URL})" == "" ] && kill -0 ${PID}; do
        sleep 2s;
    done
}

function benchmark() {
./generate_data --use-case="iot" \
--seed=123 \
--format="influx" \
--timestamp-start="2022-01-01T00:00:00Z" \
--timestamp-end="2022-02-01T00:00:00Z" \
--scale=10 | ./load_cnosdb --do-abort-on-exist=false \
--do-create-db=false \
--gzip=false \
--db-name="public" --urls="http://${HTTP_HOST}" \
--batch-size=5000 --workers=8
}

echo "Starting cnosdb"

PID=$(start_cnosdb)

echo "Wait for pid=${PID} startup."

(wait_start && benchmark) || EXIT_CODE=$?

echo "Benchmark complete, killing ${PID}"

kill ${PID}

rm -rf ./data

exit ${EXIT_CODE:-0}