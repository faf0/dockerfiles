FROM debian:13-slim AS build
RUN apt-get update && apt-get install -y dnscrypt-proxy
RUN mkdir -p /var/cache/dnscrypt-proxy/ /var/log/dnscrypt-proxy/

FROM gcr.io/distroless/base-debian13:nonroot
COPY --from=build /usr/sbin/dnscrypt-proxy /usr/bin/
COPY --from=build /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/
COPY --from=build --chown=65532:65532 /var/cache/dnscrypt-proxy /var/cache/dnscrypt-proxy
COPY --from=build --chown=65532:65532 /var/log/dnscrypt-proxy /var/log/dnscrypt-proxy
COPY dnscrypt-proxy/ /etc/dnscrypt-proxy/
USER nonroot
ENTRYPOINT ["/usr/bin/dnscrypt-proxy", "-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml"]
