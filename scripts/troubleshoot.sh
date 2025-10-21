#!/usr/bin/env bash
set -euo pipefail
echo "=== Kafka & Zookeeper diagnostics ==="
echo "Processes:"
ps aux | egrep 'kafka|zookeeper' || true
echo "Open ports (2181, 9092):"
sudo ss -tulpen | egrep '2181|9092' || true
echo "Zookeeper nodes:"
if [ -f /opt/kafka/bin/zookeeper-shell.sh ]; then
  /opt/kafka/bin/zookeeper-shell.sh localhost:2181 ls /brokers/ids || true
fi
echo "Last logs:"
tail -n 200 /tmp/kafka.log /tmp/zookeeper.log || true
