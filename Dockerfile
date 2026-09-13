FROM debian:bookworm-slim

# Avoid dynamic prompt questions during package installations
ENV DEBIAN_FRONTEND=noninteractive

# ── Attacker-machine toolset ────────────────────────────────────────────
# Grouped by purpose; everything here is apt-installable on bookworm — no
# manual/GitHub-release builds, so the image stays reproducible off a plain
# `apt-get install`.
RUN apt-get update && apt-get install -y --no-install-recommends \
    # core / shell
    curl wget git nano vim tmux screen jq unzip p7zip-full file \
    ca-certificates gnupg less \
    # networking / recon
    nmap netcat-openbsd socat openssh-client iputils-ping net-tools \
    traceroute dnsutils whois tcpdump proxychains4 \
    # web
    gobuster nikto whatweb sqlmap \
    # password/hash cracking
    john hashcat hydra \
    # binary/forensics
    gdb binutils radare2 strace ltrace binwalk exiftool steghide foremost \
    # python + pip (pwntools/impacket/requests installed below)
    python3 python3-pip pipx \
    && rm -rf /var/lib/apt/lists/*

# Debian 12 blocks bare `pip install` (PEP 668) — these are meant to sit
# alongside the system Python in a purpose-built attacker image, so
# --break-system-packages is the intended escape hatch here, not a
# workaround to walk back later.
RUN pip3 install --no-cache-dir --break-system-packages \
    pwntools requests impacket

# ── Default terminal: oh-my-bash ────────────────────────────────────────
# Installed for root first (root is the shell you get before entry.sh's
# CREATED_USER logic runs), then propagated into /etc/skel so any user
# entry.sh creates afterwards (useradd -m) inherits the same setup via its
# fresh home directory — including the entry.sh call's own append of the
# apex-terminal MOTD to that user's .bashrc.
RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" -- --unattended \
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
