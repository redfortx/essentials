#!/bin/bash
set -euo pipefail

# Clear terminal screen
clear

# Print welcome MOTD
if [ -f "/opt/apex/src/config/apex-terminal.txt" ]; then
    cat /opt/apex/src/config/apex-terminal.txt
else
    echo "LONE APEX // SYS-BOX ACTIVE"
fi

# Output active subscription/access tier
APEX_TIER="${APEX_TIER:-free}"
echo -e "\n[*] APEX_TIER: ${APEX_TIER}"

# Hold process alive in background for attachments
exec sleep infinity
