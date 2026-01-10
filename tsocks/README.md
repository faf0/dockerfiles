# tsocks

Run the static `tsocks` binary within a container.
This tool redirects applications without SOCKS support through a given SOCKS
proxy.
It uses the `LD_PRELOAD` method so it only works for dynamic target binaries.

## Build

```shell
cd tsocks
podman build -t tsocks .
```

## Run as Nonroot

```shell
podman run --rm -it --name tsocks tsocks
```

## Run as Root

```shell
podman run --rm --user root -it --name tsocks tsocks
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

### Run Application Via Socksify

Install curl in the tsocks container and use tsocks for curl to connect
```shell
cd tsocks

# Run in mynet and as root to install packages:
podman run --rm --net mynet --user root -it --name tsocks tsocks

# Install curl:
apt-get update && apt-get install -y curl && apt-get clean

# Switch to the nonroot user:
su nonroot -s /bin/bash

# Socksify curl:
# Update /etc/tsocks.conf as root or create a local one:
cat > ~/.tsocks.conf << EOF
server = tor-proxy
server_port = 9050
server_type = 4
local = 10.0.0.0/255.0.0.0
local = 172.16.0.0/255.240.0.0
local = 192.168.0.0/255.255.0.0
EOF

tsocks curl https://check.torproject.org/api/ip
```

Note that curl is chosen as an example to demonstrate tsocks.
It has native SOCKS support, so tsocks is not needed for curl.
