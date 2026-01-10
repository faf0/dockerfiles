# socksify

Run the `socksify` script from `dante-client` within a container.
This script redirects applications without SOCKS support through a given SOCKS
proxy.
It uses the `LD_PRELOAD` method so it does not work for static binaries.

## Build

```shell
cd socksify
podman build -t socksify .
```

## Run as Nonroot

```shell
podman run --rm -it --name socksify socksify
```

## Run as Root

```shell
podman run --rm --user root -it --name socksify socksify
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

Install curl in the socksify container and use socksify for curl to connect
```shell
cd socksify

# Run in mynet and as root to install packages:
podman run --rm --net mynet --user root -it --name socksify socksify

# Install curl:
apt-get update && apt-get install -y curl && apt-get clean

# Switch to the nonroot user:
su nonroot -s /bin/bash

# Socksify curl:
export SOCKS_SERVER=tor-proxy:9050
socksify curl https://check.torproject.org/api/ip
```

Note that curl is chosen as an example to demonstrate socksify.
It has native SOCKS support, so socksify is not needed for curl.
