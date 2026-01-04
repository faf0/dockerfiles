# tor-proxy

Run a SOCKS proxy for the Tor onion network within a container.

## Build

```shell
cd tor-proxy
podman build -t tor-proxy .
```

## Run

### Show Tor Version

```shell
podman run --rm -it --name tor-proxy tor-proxy --version # runs `tor --version`
```

### SOCKS Proxy

#### Configuration

The Tor proxy is configured via the files in the [tor/](tor/) folder.

E.g., the `ExitNodes` setting in [tor/torrc](tor/torrc) allows you to choose a
random exit node located in the specified country.

After changing a file in the [tor/](tor/) folder, rebuild the container so it
includes the updated config.

#### Start

Create a SOCKS proxy listening on `127.0.0.1:9050` on the Podman host to proxy
traffic through the Tor onion network.

```shell
podman run --rm -it \
  --name tor-proxy \
  -p 127.0.0.1:9050:9050 \
  tor-proxy
```

#### Test

To verify that the SOCKS proxy accepts connections and routes traffic through
the Tor network, execute the following command on your host to confirm that the
displayed IP address is from a Tor exit node:
```shell
curl -x socks5h://127.0.0.1:9050 https://check.torproject.org/api/ip
```

The curl command allows DNS to be resolved via the Tor proxy, meaning DNS
resolution occurs remotely through the Tor network.

#### Stop Proxy

To stop the container, choose one of these options:
1. Press Ctrl+C in the terminal where the container is being run.
2. Run `podman stop tor-proxy`.

