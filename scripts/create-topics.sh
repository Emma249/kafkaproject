#!/usr/bin/env bash
set -euo pipefail
KAFKA_BIN="/opt/kafka/bin"
BOOTSTRAP="${1:-localhost:9092}"
TOPIC="${2:-transactions}"
PARTITIONS="${3:-3}"
REPL="${4:-1}"

echo "Creating topic $TOPIC on $BOOTSTRAP"
$KAFKA_BIN/kafka-topics.sh --create --topic $TOPIC --bootstrap-server $BOOTSTRAP --replication-factor $REPL --partitions $PARTITIONS || true
$KAFKA_BIN/kafka-topics.sh --describe --topic $TOPIC --bootstrap-server $BOOTSTRAP
