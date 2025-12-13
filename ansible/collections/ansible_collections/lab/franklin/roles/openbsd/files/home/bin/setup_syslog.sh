#!/bin/bash
#
# SPDX-FileCopyrightText: 2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

# OpenBSD Syslogd Server Setup
# OpenBSD's base syslogd doesn't natively support TLS/SSL for remote logging so we use syslog-ng

# Define the local IP address to bind to
LISTEN_IP="10.10.12.15"

echo "Setting syslog-ng to run instead of syslogd..."


rcctl disable syslogd
rcctl enable syslog_ng
rcctl set syslog_ng flags # Clear flags if any
rcctl set syslogd flags -u "$LISTEN_IP" # This writes: syslogd_flags="-u 10.10.12.15" to /etc/rc.conf.local
echo "Review /etc/syslog-ng/syslog-ng.conf to complete TLS listener setup."
echo "Restarting services..."
rcctl stop syslogd # Ensure the old one is stopped
rcctl restart syslogd

# Pass in UDP traffic on port 514 for syslog
pass in quick proto udp from any to any port syslog