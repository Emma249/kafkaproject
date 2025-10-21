#!/usr/bin/env bash
set -euo pipefail
KAFKA_BIN="/opt/kafka/bin"
BOOTSTRAP="${1:-localhost:9092}"

echo "Consuming messages from $BOOTSTRAP (Ctrl-C to exit)"
$KAFKA_BIN/kafka-console-consumer.sh --bootstrap-server $BOOTSTRAP --topic transactions --from-beginning
