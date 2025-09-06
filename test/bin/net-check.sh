#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT


# --- Configuration ---
# Target to ping for connectivity. Google's public DNS server is a good choice.
TARGET="8.8.8.8"

# Number of packets to send in each test.
COUNT=5

# Delay between each test in seconds.
INTERVAL=10

# Log file to record timestamps of connection issues.
LOGFILE="network_status.log"

echo "Starting network connectivity and stability check..."
echo "Monitoring target: ${TARGET}"
echo "Logging outages to: ${LOGFILE}"
echo "----------------------------------------------------"

# --- Main loop ---
while true
do
    # Use ping with a quiet flag to suppress normal output, and redirect all output to /dev/null.
    # The -c flag specifies the number of packets.
    # The -q flag provides a summary only.
    ping -c ${COUNT} -q ${TARGET} >/dev/null 2>&1

    # Check the exit status of the ping command.
    # 0 means success (at least one packet was received).
    if [ $? -eq 0 ]
    then
        # If the connection is good, print a success message to the console.
        echo "$(date): All good. Latency and packet loss would be checked in a more advanced script. But for now, connectivity is stable!"
    else
        # If the ping failed, it indicates an outage.
        echo "$(date): ⚠️ WARNING: Network outage detected!"
        echo "$(date): Network outage detected." >> "${LOGFILE}"
    fi

    # Wait for the specified interval before the next check.
    sleep ${INTERVAL}
done
