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

# Dynamically create the account for the real platform user if env vars are
# present. --badname: CREATED_USER preserves the platform username's
# original case (an identity, not a display label), which useradd's own
# default NAME_REGEX would otherwise reject as invalid.
if [ -n "${CREATED_USER:-}" ]; then
    echo "[*] Creating user: ${CREATED_USER}..."
    if ! id -u "$CREATED_USER" >/dev/null 2>&1; then
        useradd -m -s /bin/bash --badname "$CREATED_USER"
        usermod -aG sudo "$CREATED_USER"
        if [ -n "${CREATED_PASSWORD:-}" ]; then
            echo "${CREATED_USER}:${CREATED_PASSWORD}" | chpasswd
        fi
        # /home/$CREATED_USER may already be a bind-mounted, pre-seeded
        # persistent volume (ensure_user_home_volume/inject_ssh_authorized_keys
        # in apex-devops) owned by that host-side process's own uid, not this
        # container's newly created user — fix ownership immediately rather
        # than leaving the user unable to read/write their own home directory
        # until a later out-of-band correction.
        chown -R "$CREATED_USER":"$CREATED_USER" "/home/${CREATED_USER}"
        # Configure welcome banner for this user
        echo 'if [ -f /opt/apex/src/config/apex-terminal.txt ]; then cat /opt/apex/src/config/apex-terminal.txt; fi' >> "/home/${CREATED_USER}/.bashrc"
    fi
fi

# Hand off to systemd as PID 1 — sysbox-runc (config.json's "runtime") is
# what makes this safe without --privileged. Everything above (user/MOTD
# setup) has to run first since systemd takes over env/PID 1 from here.
exec /sbin/init
