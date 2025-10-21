#!/usr/bin/env bash
set -euo pipefail
ROLE="${1:-broker}"  # pass 'zookeeper' or 'broker' as arg

echo "Bootstrap role: $ROLE"
sudo apt-get update -y
sudo apt-get install -y openjdk-11-jdk wget net-tools jq

KAFKA_VERSION="3.7.0"
KAFKA_DIR="/opt/kafka"
if [ ! -d "$KAFKA_DIR" ]; then
  cd /opt
  sudo wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz
  sudo tar -xzf kafka_2.13-${KAFKA_VERSION}.tgz -C /opt
  sudo mv /opt/kafka_2.13-${KAFKA_VERSION} $KAFKA_DIR
  sudo chown -R azureuser:azureuser $KAFKA_DIR
fi

export KAFKA_HOME=$KAFKA_DIR
export PATH=$PATH:$KAFKA_HOME/bin

if [ "$ROLE" = "zookeeper" ]; then
  echo "Starting Zookeeper..."
  nohup $KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties > /tmp/zookeeper.log 2>&1 &
else
  echo "Configuring broker properties..."
  # Basic broker config adjustments for cluster - expects environment variables set via cloud-init or terraform
  BROKER_ID_FILE="/etc/kafka_broker_id"
  if [ -f "$BROKER_ID_FILE" ]; then
    BROKER_ID=$(cat $BROKER_ID_FILE)
  else
    BROKER_ID=${BROKER_ID:-1}
    echo "$BROKER_ID" | sudo tee $BROKER_ID_FILE
  fi
  # Replace broker.id and listeners in server.properties (simple approach)
  sudo sed -i "s/broker.id=0/broker.id=${BROKER_ID}/" $KAFKA_HOME/config/server.properties || true
  # Start broker
  nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties > /tmp/kafka.log 2>&1 &
fi

echo "Bootstrap completed for role: $ROLE"
