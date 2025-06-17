#!/bin/bash

# Script file name
SCRIPT_PATH="/root/restart-backhauls.sh"

# Create file and write the script inside
echo '#!/bin/bash
systemctl list-unit-files | grep "backhaul-" | awk "{print \$1}" | while read svc; do
    systemctl restart "$svc"
done' > "$SCRIPT_PATH"

# Make the file executable
chmod +x "$SCRIPT_PATH"

# Add cron job
CRON_JOB="*/14 * * * * $SCRIPT_PATH"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "Script va cron job ba movafaghiat set shod."
