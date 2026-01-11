# redsocks

Run the `redsocks` tool within a container.
This tool redirects applications without SOCKS support through a
given SOCKS proxy via the redsocks daemon and iptable rules.

## Build

```shell
cd redsocks
podman build -t redsocks .
```

## Run as Nonroot

```shell
podman run --rm -it --name redsocks redsocks
```

## Run as Root

```shell
podman run --rm --user root --cap-add=NET_ADMIN -it --name redsocks redsocks
```

## Test

### Create Network

Create a network for the SOCKS client container and the SOCKS server container.
```shell
podman network create mynet
```

### Run SOCKS Server

Start a Tor SOCKS proxy on localhost:9050:
```
cd tor-proxy
podman run --rm -it \
  --name tor-proxy \
  --net mynet \
  tor-proxy
```

### Run Application Via redsocks

Install curl in the redsocks container and use redsocks for curl to connect
```shell
cd redsocks

# Run in mynet and as root to install packages:
podman run --rm --net mynet --user root --cap-add=NET_ADMIN -it --name redsocks redsocks

# Install iptables rules:
/root/iptables.sh

# Restart redsocks:
service redsocks restart

# Check whether it is running (it might still be running even if
# the command says it failed):
service redsocks status

# Install curl:
apt-get update && apt-get install -y curl && apt-get clean

# Switch to the nonroot user:
su nonroot -s /bin/bash

# Run curl through tor-proxy with the help of redsocks:
curl https://check.torproject.org/api/ip
```

Note that curl is chosen as an example to demonstrate redsocks.
It has native SOCKS support, so redsocks is not needed for curl.

Redsocks redirects TCP traffic, whereas traffic for other transport
layer protocols like UDP is not necessarily redirected through the
SOCKS proxy.
In the context of Tor, it is therefore better to use Tor-native
software instead, such as Tor browser, Whonix, or Tails.

After changing redsocks.conf, do not forget to rebuild and rerun
the container.
