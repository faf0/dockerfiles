#!/usr/bin/env sh

# Create redsocks chain
iptables -t nat -N REDSOCKS

# Ignore private networks
iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
# Add more networks if needed:
# https://github.com/darkk/redsocks?tab=readme-ov-file#iptables-example

# Redirect remaining traffic to redsocks
iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345

# Apply to nonroot user traffic
iptables -t nat -A OUTPUT -p tcp -m owner --uid-owner nonroot -j REDSOCKS
