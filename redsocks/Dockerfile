FROM debian:sid-slim
RUN apt-get update && \
    apt-get install -y redsocks iptables && \
    apt-get clean
RUN useradd -m nonroot
COPY redsocks.conf /etc/
COPY iptables.sh /root/
USER nonroot
CMD ["/bin/bash"]
