#!/bin/bash

# Script file path
SCRIPT_PATH="/root/restart-backhauls.sh"

# Create the script file and write the content
echo '#!/bin/bash
systemctl list-unit-files | grep "backhaul-" | awk "{print \$1}" | while read svc; do
    systemctl restart "$svc"
done' > "$SCRIPT_PATH"

# Make the script executable
chmod +x "$SCRIPT_PATH"

# Define cron job command
CRON_JOB="*/14 * * * * $SCRIPT_PATH"

# Add the cron job
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

# Final message
echo "✅ Script va cron job ba movafaghiat set shod."
