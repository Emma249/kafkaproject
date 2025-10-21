#!/bin/bash
mkdir -p /home/azureuser/scripts
chown azureuser:azureuser /home/azureuser/scripts || true
echo "Userdata placeholder" > /home/azureuser/scripts/placeholder.txt
