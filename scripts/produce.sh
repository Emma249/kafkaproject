#!/usr/bin/env bash
set -euo pipefail
KAFKA_BIN="/opt/kafka/bin"
BOOTSTRAP="${1:-localhost:9092}"
MSG="${2:-'{"user":"test","amount":100.0}'}"

echo "Producing message to $BOOTSTRAP"
echo -e $MSG | $KAFKA_BIN/kafka-console-producer.sh --broker-list $BOOTSTRAP --topic transactions
