#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT


TARGET="8.8.8.8"
COUNT=10
LOGFILE="network_stability.log"

echo "Starting network stability check..."
echo "Monitoring target: ${TARGET}"
echo "Logging results to: ${LOGFILE}"
echo "----------------------------------------------------"

while true
do
    # Run ping and capture its output
    ping_output=$(ping -c ${COUNT} ${TARGET})

    # Extract packet loss percentage and average latency
    packet_loss=$(echo "${ping_output}" | grep "packet loss" | awk '{print $6}' | sed 's/%//')
    avg_latency=$(echo "${ping_output}" | grep "round-trip" | awk '{print $4}' | cut -d'/' -f2)

    if [ -n "${avg_latency}" ]
    then
        echo "$(date): Packet Loss: ${packet_loss}%, Avg Latency: ${avg_latency} ms" | tee -a "${LOGFILE}"
    else
        echo "$(date): ⚠️ WARNING: Network outage or target unreachable!" | tee -a "${LOGFILE}"
    fi

    # Wait for 10 seconds before the next check
    sleep 10
done
