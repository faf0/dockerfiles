FROM debian:forky-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools, Python, and runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    git \
    libcurl4-openssl-dev \
    libgomp1 \
    ninja-build \
    python3 \
    python3-pip \
    python3-venv \
    sudo \
    unzip \
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
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}"
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

# Install bun
ENV BUN_INSTALL="/home/${USERNAME}/.bun"
ENV PATH="${BUN_INSTALL}/bin:${PATH}"
RUN curl -fsSL https://bun.com/install -o /tmp/install-bun.sh && \
    test -s /tmp/install-bun.sh && \
    bash /tmp/install-bun.sh && \
    mv /tmp/install-bun.sh "${BUN_INSTALL}/" && \
    ln -s "$(which bun)" "${BUN_INSTALL}/bin/node"

# Install Pi
RUN bun add -g --ignore-scripts @earendil-works/pi-coding-agent
ENV PATH="/home/${USERNAME}/.pi:${PATH}"
RUN mkdir -p /home/${USERNAME}/.pi/agent && \
    printf '%s\n' \
    '{' \
    '  "$schema": "https://pi.dev/schemas/models.schema.json",' \
    '  "providers": {' \
    '    "llama-modchip": {' \
    '      "baseUrl": "http://127.0.0.1:8787",' \
    '      "api": "openai-completions",' \
    '      "apiKey": "local",' \
    '      "models": [' \
    '        {' \
    '          "id": "llama-modchip"' \
    '        }' \
    '      ]' \
    '    }' \
    '  }' \
    '}' > /home/${USERNAME}/.pi/agent/models.json

# Install OpenCode
RUN bun add -g --trust @opencode/cli
ENV PATH="/home/${USERNAME}/.opencode/bin:${PATH}"
RUN mkdir -p /home/${USERNAME}/.config/opencode && \
    printf '%s\n' \
    '{' \
    '  "$schema": "https://opencode.ai",' \
    '  "model": "local/llama-modchip",' \
    '  "provider": {' \
    '    "local": {' \
    '      "npm": "@ai-sdk/openai-compatible",' \
    '      "name": "Local Server",' \
    '      "options": {' \
    '        "baseURL": "http://127.0.0.1:8787",' \
    '        "apiKey": "local"' \
    '      },' \
    '      "models": {' \
    '        "llama-modchip": {' \
    '          "name": "Local Modchip Model"' \
    '        }' \
    '      }' \
    '    }' \
    '  }' \
    '}' > /home/${USERNAME}/.config/opencode/opencode.json

WORKDIR /workspace
CMD ["/usr/bin/env", "bash"]
