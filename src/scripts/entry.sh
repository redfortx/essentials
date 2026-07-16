#!/bin/bash
set -euo pipefail

# Welcome MOTD

# Print welcome MOTD
if [ -f "/opt/apex/src/config/apex-terminal.txt" ]; then
    cat /opt/apex/src/config/apex-terminal.txt
else
    echo "LONE APEX"
fi

# Output active subscription/access tier
APEX_TIER="${APEX_TIER:-free}"
echo -e "\n[*] APEX_TIER: ${APEX_TIER}"

# Dynamically create unprivileged user if env vars are present
if [ -n "${CREATED_USER:-}" ]; then
    echo "[*] Creating user: ${CREATED_USER}..."
    if ! id -u "$CREATED_USER" >/dev/null 2>&1; then
        useradd -m -s /bin/bash "$CREATED_USER"
        if [ -n "${CREATED_PASSWORD:-}" ]; then
            echo "${CREATED_USER}:${CREATED_PASSWORD}" | chpasswd
        fi
        # Configure welcome banner for this user
        echo 'if [ -f /opt/apex/src/config/apex-terminal.txt ]; then cat /opt/apex/src/config/apex-terminal.txt; fi' >> "/home/${CREATED_USER}/.bashrc"
    fi
fi

# Hold process alive in background for attachments
exec sleep infinity
