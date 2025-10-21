#!/usr/bin/env bash
set -euo pipefail
sudo useradd --no-create-home --shell /bin/false prometheus || true
sudo mkdir -p /etc/prometheus /var/lib/prometheus
cd /tmp
PROM_VER=2.53.0
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VER}/prometheus-${PROM_VER}.linux-amd64.tar.gz
tar xvf prometheus-${PROM_VER}.linux-amd64.tar.gz
sudo mv prometheus-${PROM_VER}.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-${PROM_VER}.linux-amd64/promtool /usr/local/bin/
sudo cp -r prometheus-${PROM_VER}.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-${PROM_VER}.linux-amd64/console_libraries /etc/prometheus
sudo cp /home/azureuser/monitoring/prometheus.yml /etc/prometheus/prometheus.yml
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus || true
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
echo "Prometheus installed and running on port 9090"
