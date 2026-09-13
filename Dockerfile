FROM debian:bookworm-slim

# Avoid dynamic prompt questions during package installations
ENV DEBIAN_FRONTEND=noninteractive

# ── Starter toolset ──────────────────────────────────────────────────────
# Kept deliberately lean — heavier compiled/dependency-chain tools
# (hashcat, john, hydra, whatweb, sqlmap, radare2, nikto, gdb/binutils,
# binwalk, steghide, foremost) pull in large toolchains each and slowed
# the build enough to get killed; add them back individually later if a
# specific lab actually needs one.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git python3 python3-pip nmap netcat-openbsd socat jq \
    nano vim openssh-client dnsutils whois tcpdump unzip \
    && rm -rf /var/lib/apt/lists/*

# Debian 12 blocks bare `pip install` (PEP 668) — meant to sit alongside
# the system Python in a purpose-built lab image, so --break-system-packages
# is the intended escape hatch here, not a workaround to walk back later.
RUN pip3 install --no-cache-dir --break-system-packages requests

# ── Default terminal: oh-my-bash ────────────────────────────────────────
# Installed for root first (root is the shell you get before entry.sh's
# CREATED_USER logic runs), then propagated into /etc/skel so any user
# entry.sh creates afterwards (useradd -m) inherits the same setup via its
# fresh home directory — including the entry.sh call's own append of the
# apex-terminal MOTD to that user's .bashrc.
RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" \
    && cp -r /root/.oh-my-bash /etc/skel/.oh-my-bash \
    && sed 's#/root/.oh-my-bash#'"'"'$HOME'"'"'/.oh-my-bash#' /root/.bashrc > /etc/skel/.bashrc \
    && chmod -R a+rX /etc/skel/.oh-my-bash

# Set up clean persistent/ephemeral workspace
WORKDIR /workspace

# Copy files
COPY src/ /opt/apex/src/

# Grant execute rights on bootstrap scripts
RUN chmod +x /opt/apex/src/scripts/entry.sh

# Run entry bootstrap script
ENTRYPOINT ["/bin/bash", "/opt/apex/src/scripts/entry.sh"]
