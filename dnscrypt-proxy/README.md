# dnscypt-proxy

Run dnscrypt-proxy for encrypted DNS resolution within a container.

The supported protocols include:
- DNS-over-HTTPS (DoH)
- Oblivious DoH (ODoH)
- DNSCrypt v2
- Anonymized DNSCrypt

## Build

```shell
cd dnscrypt-proxy
podman build -t dnscrypt-proxy .
```

## Run

### Show Version

```shell
podman run --rm -it --name dnscrypt-proxy dnscrypt-proxy --version
```

### Configure

The dnscrypt-proxy is configured via
[dnscrypt-proxy/dnscrypt-proxy.toml](dnscrypt-proxy/dnscrypt-proxy.toml).
For the `server_names` setting, pick one or more servers from
https://dnscrypt.info/public-servers.

After changing the configuration, rebuild the container so it includes the
updated file.

### Start

Create a dnscrypt-proxy listening on `127.0.0.1:5353` on the Podman host for
DNS resolution.

```shell
podman run --rm -it \
  --name dnscrypt-proxy \
  -p 127.0.0.1:5353:5353 \
  dnscrypt-proxy
```

On Linux with systemd-resolved, configure a DNS stub resolver on port 53 to
route DNS queries through the dnscrypt-proxy instance on port 5353.
Edit `/etc/systemd/resolved.conf` accordingly:
```
[Resolve]
DNS=127.0.0.1:5353
FallbackDNS=
DNSStubListener=yes
Domains=~.
```

Restart systemd-resolved:
```shell
sudo systemctl restart systemd-resolved.service
```

### Test

Resolve an arbitrary domain through the system default name server on your
host:
```shell
nslookup google.com
```
