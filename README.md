# Kafka on Azure using Terraform (Production-like)

This repository contains Terraform and automation scripts to deploy a **multi-node Apache Kafka cluster** on **Microsoft Azure**.
It includes separate VMs for Kafka brokers, Zookeeper, and a dedicated monitoring VM for Prometheus & Grafana. The setup is
intended as a production-like deployment for SRE and DevOps demonstration.

## Structure
kafkaproject/
├── README.md
├── scripts/
│   ├── kafka-bootstrap.sh
│   ├── create-topics.sh
│   ├── produce.sh
│   ├── consume.sh
│   ├── troubleshoot.sh
│   ├── install-prometheus.sh
│   └── install-grafana.sh
├── monitoring/
│   ├── prometheus.yml
│   └── dashboards/kafka-overview.json
├── terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── outputs.tf
└── .gitignore

## Quick Start (high level)
1. Ensure Terraform v1.9+ and Azure CLI are installed and authenticated (`az login`).
2. Update `terraform/variables.tf` with your values (resource names, SSH public key path, location).
3. Run: `terraform init && terraform plan -out=tfplan && terraform apply tfplan`
4. After VMs are created, SSH into the VMs and run bootstrap scripts in `/home/user/scripts/`.
   - Zookeeper VM: `sudo bash kafka-bootstrap.sh zookeeper`
   - Broker VMs: `sudo bash kafka-bootstrap.sh broker`
   - Monitoring VM: `sudo bash install-prometheus.sh` and `sudo bash install-grafana.sh`
5. Create topics & test producer/consumer: `sudo bash create-topics.sh && sudo bash produce.sh && sudo bash consume.sh`

## Troubleshooting Highlights
- Broker not responding: check `ps aux | grep kafka`, view logs `/tmp/kafka.log` and ensure ports (9092) open.
- Zookeeper issues: check `/tmp/zookeeper.log` and znode state with `zookeeper-shell.sh`.
- Monitoring: ensure Prometheus targets include broker JMX exporter endpoints and that Grafana datasource points to Prometheus.

## Notes
- this repo simulates event-driven production environments with secure access, managed disks, private networks.
