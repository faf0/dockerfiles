FROM debian:13-slim AS build
RUN apt-get update && apt-get install -y tor

FROM gcr.io/distroless/base-debian13:nonroot
COPY --from=build /usr/bin/tor /usr/bin/tor
COPY --from=build /usr/bin/torsocks /usr/bin/torsocks
COPY --from=build /usr/bin/tor-resolve /usr/bin/tor-resolve
COPY --from=build /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libcap.so.2 /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libcrypto.so.3 /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libevent-2.1.so.7 /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/liblzma.so.5 /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libm.so.6 /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libseccomp.so.2 /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libssl.so.3 /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libsystemd.so.0 /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/
COPY --from=build /lib/x86_64-linux-gnu/libzstd.so.1 /lib/x86_64-linux-gnu/
COPY --from=build /usr/share/tor/ /usr/share/tor/
COPY tor/ /etc/tor/
USER nonroot
ENTRYPOINT ["/usr/bin/tor"]
