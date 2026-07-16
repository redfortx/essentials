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

# Create unprivileged user with UID 1046
RUN useradd -u 1046 -m -s /bin/bash pevin

# Set up clean persistent/ephemeral workspace
WORKDIR /workspace
RUN chown -R pevin:pevin /workspace

# Copy files and grant ownership to the unprivileged user
COPY --chown=pevin:pevin src/ /opt/apex/src/

# Grant execute rights on bootstrap scripts
RUN chmod +x /opt/apex/src/scripts/entry.sh

# Configure automatic welcome banner print upon interactive shell attachments
RUN echo 'if [ -f /opt/apex/src/config/apex-terminal.txt ]; then cat /opt/apex/src/config/apex-terminal.txt; fi' >> /home/pevin/.bashrc

# Lower security context to unprivileged account
USER pevin

# Run entry bootstrap script
ENTRYPOINT ["/bin/bash", "/opt/apex/src/scripts/entry.sh"]
