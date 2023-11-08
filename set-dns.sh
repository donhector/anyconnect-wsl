#!/usr/bin/env bash

# Get the current DNS server address from the Windows host
# Any output coming from Windows executables needs to get carriage return removed
# We are only interested in the second line, second column of the nslookup output
host_dns_address=$(powershell.exe -Command nslookup 1.1.1.1 | tr -d '\r' | awk 'NR==2{print $2;exit}')

cat << EOF | sudo tee /etc/resolv.conf
# This file was autogenered by a script. Manual changes will be lost.
# Last generated at: $(date '+%F %T')
nameserver $host_dns_address
EOF
