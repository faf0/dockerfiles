FROM debian:forky-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools, Python, and runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ninja-build \
    git \
    curl \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    libcurl4-openssl-dev \
    libgomp1 \
    sudo \
    && apt-get clean

# Create a non-root user named 'llm' (UID/GID 1000 if available, otherwise next available)
ARG USERNAME=llm
ARG USER_UID=1000
ARG USER_GID=1000
RUN if id -u ${USER_UID} >/dev/null 2>&1; then userdel -r $(id -un ${USER_UID}); fi && \
    groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME}
# Add the user to the sudo group
RUN usermod -aG sudo "$USERNAME"
# Configure NOPASSWD so sudo works without password entry
# Create a sudoers file for the user
RUN echo "%myuser ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}"
# Set proper permissions on the sudoers file
RUN chmod 0440 "/etc/sudoers.d/${USERNAME}"

# Prepare directories owned by 'llm'
RUN mkdir -p /opt/llama-modchip /workspace

# Switch to non-root user for source setup, compilation, and OpenCode installation
USER ${USERNAME}
WORKDIR /opt/llama-modchip

# Copy local llama-modchip source if present in build context; otherwise fall back to git clone
RUN if [ -f ./install.sh ]; then \
        echo "Using local llama-modchip source..." ; \
    else \
        echo "Local source not found; cloning from GitHub..." && \
        git clone --depth 1 https://github.com/synchopate/llama-modchip ; \
    fi

# Download OpenCode v2 install script to a file first, inspect/verify non-empty, then run it
RUN curl -fsSL https://opencode.ai/v2/install -o /tmp/install-opencode.sh && \
    test -s /tmp/install-opencode.sh && \
    bash /tmp/install-opencode.sh && \
    mv /tmp/install-opencode.sh "/home/${USERNAME}/"

ENV PATH="/home/${USERNAME}/.opencode/bin:${PATH}"

# Pre-configure OpenCode to connect to the local llama-modchip server
RUN mkdir -p /home/${USERNAME}/.config/opencode && \
    printf '%s\n' \
    '{' \
    '  "$schema": "https://opencode.ai",' \
    '  "provider": {' \
    '    "llama-modchip": {' \
    '      "npm": "@ai-sdk/openai-compatible",' \
    '      "name": "llama-modchip (Local CPU)",' \
    '      "options": {' \
    '        "baseURL": "http://127.0.0.1:8787/v1",' \
    '        "apiKey": "local",' \
    '        "timeout": 600000' \
    '      },' \
    '      "models": {' \
    '        "local-moe": {' \
    '          "name": "Local Modchip Model",' \
    '          "tool_call": true' \
    '        }' \
    '      }' \
    '    }' \
    '  }' \
    '}' > /home/${USERNAME}/.config/opencode/opencode.json

WORKDIR /workspace
CMD ["/bin/bash"]
