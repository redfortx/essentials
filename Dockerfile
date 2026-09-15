FROM debian:bookworm-slim

# Avoid dynamic prompt questions during package installations
ENV DEBIAN_FRONTEND=noninteractive

# ── Starter toolset ──────────────────────────────────────────────────────
# Kept deliberately lean — heavier compiled/dependency-chain tools
# (hashcat, john, hydra, whatweb, sqlmap, radare2, nikto, gdb/binutils,
# binwalk, steghide, foremost) pull in large toolchains each and slowed
# the build enough to get killed; add them back individually later if a
# specific lab actually needs one.
# systemd/systemd-sysv: this image runs under sysbox-runc (see
# essentials/config.json's "runtime"), which is specifically built to run
# an unmodified systemd as PID 1 safely inside an unprivileged container —
# no --privileged, no manual cgroup/mount workarounds needed.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git python3 python3-pip nmap netcat-openbsd socat jq \
    nano vim openssh-client dnsutils whois tcpdump unzip sudo \
    systemd systemd-sysv \
    && rm -rf /var/lib/apt/lists/* \
    # Masked: these mount/create real kernel interfaces (debug/config/trace
    # fs, static device nodes) that don't exist in any container, sysbox or
    # not — always fail and leave systemd reporting "degraded" otherwise.
    && systemctl mask sys-kernel-config.mount sys-kernel-debug.mount \
        sys-kernel-tracing.mount kmod-static-nodes.service

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

# systemd's expected shutdown signal — without this, `docker stop` sends
# SIGTERM (which systemd-as-PID1 doesn't treat as a clean shutdown request)
# and the container hangs until the kill timeout.
STOPSIGNAL SIGRTMIN+3

# Run entry bootstrap script — sets up the MOTD/user, then hands off to
# systemd (see entry.sh's final exec) instead of just idling.
ENTRYPOINT ["/bin/bash", "/opt/apex/src/scripts/entry.sh"]
