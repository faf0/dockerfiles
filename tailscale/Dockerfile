FROM docker.io/tailscale/tailscale:stable AS tailscale

FROM docker.io/library/debian:13-slim AS debian
RUN apt-get update && \
    apt-get install -y iptables && \
    apt-get clean
# tailscale uses iptables-legacy at the moment
RUN rm /usr/sbin/iptables \
       /usr/sbin/ip6tables
RUN ln -s /usr/sbin/xtables-legacy-multi /usr/sbin/iptables && \
    ln -s /usr/sbin/xtables-legacy-multi /usr/sbin/ip6tables
RUN mkdir -p /run && touch /run/xtables.lock
RUN mkdir -p /var/lib/tailscale

FROM gcr.io/distroless/base-debian13:nonroot
COPY --from=debian /usr/sbin/xtables-legacy-multi /usr/sbin/
COPY --from=debian /usr/sbin/iptables /usr/sbin/
COPY --from=debian /usr/sbin/ip6tables /usr/sbin/
COPY --from=debian /lib/x86_64-linux-gnu/libxtables.so.12 /lib/x86_64-linux-gnu/
COPY --from=debian /lib/x86_64-linux-gnu/libip4tc.so.2 /lib/x86_64-linux-gnu/
COPY --from=debian /lib/x86_64-linux-gnu/libip6tc.so.2 /lib/x86_64-linux-gnu/
COPY --from=debian /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/
COPY --from=debian --chown=nonroot:nonroot /run/xtables.lock /run/
COPY --from=debian --chown=nonroot:nonroot /var/lib/tailscale /var/lib/
COPY --from=tailscale /usr/local/bin/containerboot /usr/local/bin/
COPY --from=tailscale /usr/local/bin/tailscaled /usr/local/bin/
COPY --from=tailscale /usr/local/bin/tailscale /usr/local/bin/
USER nonroot
ENTRYPOINT ["/usr/local/bin/containerboot"]
