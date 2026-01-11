# proxychains-ng

Run the `proxychains-ng` tool within a container.
This tool redirects applications without SOCKS support through a given SOCKS
proxy.
It uses the `LD_PRELOAD` method so it only works for dynamic target binaries.

## Build

```shell
cd proxychains-ng
podman build -t proxychains-ng .
```

## Run as Nonroot

```shell
podman run --rm -it --name proxychains-ng proxychains-ng
```

## Run as Root

```shell
podman run --rm --user root -it --name proxychains-ng proxychains-ng
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

### Run Application Via proxychains-ng

Install curl in the proxychains-ng container and use proxychains-ng for curl to connect
```shell
cd proxychains-ng

# Run in mynet and as root to install packages:
podman run --rm --net mynet --user root -it --name proxychains-ng proxychains-ng

# Install curl:
apt-get update && apt-get install -y curl && apt-get clean

# Switch to the nonroot user:
su nonroot -s /bin/bash

# Run curl through proxychains-ng:
# Update /etc/proxychains4.conf as root or create a local one:
mkdir -p ~/.proxychains
cat > ~/.proxychains/proxychains.conf << EOF
strict_chain

proxy_dns
remote_dns_subnet 224

tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
socks4 $(getent hosts tor-proxy | cut -d' ' -f1) 9050
EOF

proxychains curl https://check.torproject.org/api/ip
```

Note that curl is chosen as an example to demonstrate proxychains-ng.
It has native SOCKS support, so proxychains-ng is not needed for curl.

The IP address of the SOCKS server is required in the config.
The host name `tor-proxy` cannot be used.
