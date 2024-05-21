#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" >&2
   exit 1
fi

# Dependency checks
type apt-get >/dev/null 2>&1 || { echo "apt-get command not found"; exit 1; }
type crontab >/dev/null 2>&1 || { echo "crontab command not found"; exit 1; }

# Set variables
LOG_UPDATE="/var/log/update_script.log"
LOG_INSTALL="/var/log/install_script.log"
AUTO_UPGRADES_FILE="/etc/apt/apt.conf.d/20auto-upgrades"
UNATTENDED_UPGRADES_FILE="/etc/apt/apt.conf.d/50unattended-upgrades"

# Update and install unattended-upgrades and apt-listchanges
echo "Updating package lists..."
apt-get update >> $LOG_UPDATE 2>&1 || { echo "Failed to update package lists"; exit 1; }

echo "Installing unattended-upgrades and apt-listchanges package..."
apt-get install unattended-upgrades apt-listchanges -y >> $LOG_INSTALL 2>&1 || { echo "Failed to install packages"; exit 1; }

# Enable unattended-upgrades if not already enabled
if [[ ! -f $AUTO_UPGRADES_FILE ]]; then
    echo "Enabling automatic updates..."
    cat > "$AUTO_UPGRADES_FILE" << EOF_AUTO_UPGRADES || { echo "Failed to write $AUTO_UPGRADES_FILE"; exit 1; }
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF_AUTO_UPGRADES
else
    echo "Automatic updates already enabled."
fi

# Configure unattended-upgrades to upgrade all packages, excluding proposed and backports by default
echo "Configuring unattended-upgrades..."
[ -f "$UNATTENDED_UPGRADES_FILE" ] && cp "$UNATTENDED_UPGRADES_FILE" "${UNATTENDED_UPGRADES_FILE}.bak"
cat > "$UNATTENDED_UPGRADES_FILE" << EOF_UNATTENDED_UPGRADES || { echo "Failed to write $UNATTENDED_UPGRADES_FILE"; exit 1; }
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}";
    "\${distro_id}:\${distro_codename}-security";
    "\${distro_id}ESMApps:\${distro_codename}-apps-security";
    "\${distro_id}ESM:\${distro_codename}-infra-security";
    "\${distro_id}:\${distro_codename}-updates";
};
Unattended-Upgrade::Package-Blacklist {
};
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOF_UNATTENDED_UPGRADES

# Set up a cron job to run unattended-upgrades every 3 days
echo "Setting up cron job for unattended upgrades every 3 days..."
(crontab -l 2>/dev/null | grep -v unattended-upgrade; echo "0 0 */3 * * $(command -v unattended-upgrade || echo '/usr/bin/unattended-upgrade')") | crontab - || { echo "Failed to update crontab"; exit 1; }

echo "Setup complete. System will now automatically check for and apply updates every 3 days."
