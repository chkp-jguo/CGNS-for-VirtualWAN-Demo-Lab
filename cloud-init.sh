#!/bin/bash

# Update the package repository and install necessary packages
sudo apt-get update
sudo sudo apt-get install -y telnet net-tools inetutils-ping netcat tcpdump vim iperf iperf3
sudo timedatectl set-timezone America/Los_Angeles

# Add environment variables to .bashrc
# echo "export MY_VAR=my_value" >> /home/ubuntu/.bashrc
# echo "export ANOTHER_VAR=another_value" >> /home/ubuntu/.bashrc

# Source the .bashrc file to apply the changes
# source /home/ubuntu/.bashrc