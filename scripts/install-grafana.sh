#!/usr/bin/env bash
set -euo pipefail
sudo apt-get update -y
sudo apt-get install -y apt-transport-https software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
sudo apt-get update -y
sudo apt-get install grafana -y
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
echo "Grafana running on port 3000 (admin/admin)"
