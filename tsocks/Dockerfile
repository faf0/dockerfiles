FROM debian:sid-slim
RUN apt-get update && \
    apt-get install -y tsocks && \
    apt-get clean
RUN useradd -m nonroot
USER nonroot
CMD ["/bin/bash"]
