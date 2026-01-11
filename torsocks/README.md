# torsocks

Run the `torsocks` tool within a container.
This tool redirects applications without SOCKS support through a
given (Tor) SOCKS proxy.
It uses the `LD_PRELOAD` method so it only works for dynamic target
binaries.

## Build

```shell
cd torsocks
podman build -t torsocks .
```

## Run as Nonroot

```shell
podman run --rm -it --name torsocks torsocks
```

## Run as Root

```shell
podman run --rm --user root -it --name torsocks torsocks
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

### Run Application Via torsocks

Install curl in the torsocks container and use torsocks for curl to connect
```shell
cd torsocks

# Run in mynet and as root to install packages:
podman run --rm --net mynet --user root -it --name torsocks torsocks

# Install curl:
apt-get update && apt-get install -y curl && apt-get clean

# Switch to the nonroot user:
su nonroot -s /bin/bash

# Run curl through torsocks:
TOR_IP=$(getent hosts tor-proxy | cut -d' ' -f1)
torsocks -a "$TOR_IP" -P 9050 curl https://check.torproject.org/api/ip
```

Note that curl is chosen as an example to demonstrate torsocks.
It has native SOCKS support, so torsocks is not needed for curl.
