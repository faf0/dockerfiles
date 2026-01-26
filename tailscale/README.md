# Tailscale

Run Tailscale in a distroless container for a reduced attack surface.

## Build

```shell
cd tailscale
sudo podman build -t tailscale .
```

The container images is built as root, so Podman will be able to find the local
image when starting the rootfull container.

## Generate Auth Key

Generate an auth key for your Tailscale device in the web administration
interface:
https://tailscale.com/kb/1085/auth-keys#generate-an-auth-key

Consider making the key non-reusable and ephemeral.

## Run

### Host Networking

Start Tailscale in the foreground as follows:
```shell
sudo podman run --rm --name=tailscaled --device=/dev/net/tun --network=host --cap-add=NET_ADMIN,NET_RAW -e TS_USERSPACE=0 -e TS_HOSTNAME=myhost -e TS_AUTHKEY=tskey-auth-ab1CDE2CNTRL-0123456789abcdef tailscale
```

- Add the flag `-d` to run Tailscale in the background.
- Add the flag `-v /var/lib:/var/lib` to store logs and configs in your local
  `/var/lib/tailscale` folder.
- The flag `--network=host` flag connects the Tailscale container's network to
  the host network in Podman, allowing Tailscale to access network services
  from the host.
- The container is rootfull to provide sufficient network privileges.
  Networking privileges are still minimized using the `--cap-add` flags.

### Container Networking

Omit the `--network=host` flag when starting Tailscale to restrict Tailscale to
a Podman-managed container network.

### Userspace Networking

When your host kernel does not have a network TUN device, you can enable
userspace networking instead:
- Omit the following flags:
  - `-e TS_USERSPACE=0`
  - `--device=/dev/net/tun`
- Add  the following flags:
  - `-e TS_SOCKS5_SERVER=127.0.0.1:1055`
  - `-e TS_OUTBOUND_HTTP_PROXY_LISTEN=127.0.0.1:1055`

Userspace networking can be used with host networking or container networking.
For container networking, omit `127.0.0.1` for the SOCKS5 and HTTP proxy to
listen on all network interfaces, making the proxy socket available to other
containers sharing the Tailscale container network namespace.

Incoming connections work in both userspace networking mode and tunneling mode
using the TUN device. For applications running in containers on your Tailscale
host to establish outgoing connections to your tailnet, Tailscale needs to
either utilize a TUN device or operate in userspace networking mode while
offering a SOCKS5 or HTTP proxy for those applications.

In case your containerized application does not offer native SOCKS5 or HTTP
proxy support, refer to https://ffoerg.de/posts/2026-01-11.shtml for options to
still let your application connect to Tailscale's proxy. 

On my machine, I couldn't get userspace networking to work due to ["socks5:
client connection failed: context deadline exceeded"
errors](https://github.com/tailscale/tailscale/issues/14956) in the Tailscale
logs when an application tries to connect to the Tailscale SOCKS5 proxy. When
trying to connect via Tailscale's HTTP proxy, the Tailscale logs showed "http:
proxy error: context canceled".

## Approve Machine

To add the device to your tailnet, visit the web administration interface:
https://login.tailscale.com/admin/machines

## Test

### Host Networking

Run a container with netcat listening on port 1234 on the Podman host running
Tailscale:
```shell
podman run --name=nc-server -p 1234:1234 --rm alpine:3.23 sh -c 'nc -l -p 1234'
```

Note that binding the socket to localhost via `-p 127.0.0.1:1234:1234` won't
make the nc-server socket available inside your tailnet.

Connect to your Tailscale machine from anywhere within your tailnet with
netcat:
```shell
nc <public-IP-address-of-Tailscale-machine> 1234
type something and hit return
make sure the line is printed in nc-server's terminal
```

Example with curl:
```shell
curl http://<public-IP-address-of-Tailscale-machine>:1234/
```

The nc-server terminal should print a `GET /` request.

### Container Networking

Run a container with netcat listening on port 1234 in Tailscale's container
network:
```shell
sudo podman run --name=nc-server --network=container:tailscaled --rm alpine:3.23 sh -c 'nc -l -p 1234'
```

The command is intentionally run as root for the nc-server container to be able
to access the network of the rootfull Tailscale container.

To connect to nc-server, spin up an nc-client container with access to the
Tailscale container network:
```shell
sudo podman run --name=nc-client --network=container:tailscaled --rm -it alpine:3.23 sh
```

In the container shell, run `nc <public-IP-address-of-Tailscale-machine> 1234`
and enter one or more lines to confirm that the nc-server prints them.

### Userspace Networking

Userspace networking did not work due to the SOCKS and HTTP proxy errors
mentioned above.

## Stop

Press Ctrl+C in the terminal the container runs in if run in foreground.
Alternatively, run the following in a new terminal:
```shell
sudo podman stop tailscaled
```

Remove your machine in the Tailscale web administration interface:
https://login.tailscale.com/admin/machines

## References

- For Tailscale environment variables and flags, refer to the [official
  Tailscale container
  instructions](https://hub.docker.com/r/tailscale/tailscale), as the official
  Tailscale container works in the same fashion.
- For Tailscale userspace networking, refer to
  https://tailscale.com/kb/1112/userspace-networking.
- For rootfull and rootless networking in Podman, refer to
  https://www.redhat.com/en/blog/container-networking-podman.
- For proxying application traffic through a SOCKS proxy when an application
  lacks native proxy support, refer to
  https://ffoerg.de/posts/2026-01-11.shtml.

