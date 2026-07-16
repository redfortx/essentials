FROM debian:bookworm-slim

# Avoid dynamic prompt questions during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Install essential CTF packages and tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    nmap \
    netcat-openbsd \
    jq \
    nano \
    vim \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Set up clean persistent/ephemeral workspace
WORKDIR /workspace

# Copy files
COPY src/ /opt/apex/src/

# Grant execute rights on bootstrap scripts
RUN chmod +x /opt/apex/src/scripts/entry.sh

# Run entry bootstrap script
ENTRYPOINT ["/bin/bash", "/opt/apex/src/scripts/entry.sh"]
