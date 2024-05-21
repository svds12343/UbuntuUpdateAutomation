# Auto Update Script for Debian/Ubuntu

This script sets up automatic updates on Debian and Ubuntu systems. It ensures that the system automatically installs updates for security and other essential packages, and it configures the system to reboot if needed.

## Features

- Checks and ensures the script is running with root privileges.
- Installs and configures `unattended-upgrades` and `apt-listchanges`.
- Updates package lists and installs necessary packages while logging the operations.
- Sets up automatic updates by writing configurations to `/etc/apt/apt.conf.d/`.
- Configures `unattended-upgrades` to upgrade all packages and exclude certain repositories.
- Sets up a cron job to automatically check for updates every 3 days.
- Backs up existing configurations before making changes.

## Prerequisites

Before running this script, make sure your system meets the following requirements:

- Debian or Ubuntu-based distribution.
- The `apt-get` and `crontab` commands must be available.
- The script must be run as `root` or with `sudo` privileges.

## Installation

To use this script:

1. **Download the Script**
   - Clone this repository or download the script directly using the following command:
     ```bash
     wget https://raw.githubusercontent.com/svds12343/UbuntuUpdateAutomation/main/autoupdatescript.sh
     ```

2. **Make the Script Executable**
   - Change the permission of the script file to make it executable:
     ```bash
     chmod +x autoupdatescript.sh
     ```

3. **Run the Script**
   - Execute the script as `root`:
     ```bash
     sudo ./autoupdatescript.sh
     ```

## Usage

After installation, the script does the following:

- Logs update attempts and results to `/var/log/update_script.log`.
- Logs installation attempts and results to `/var/log/install_script.log`.
- Checks for updates and applies them automatically every 3 days at midnight.

You can check the logs to see the details of what was updated:

```bash
cat /var/log/update_script.log
cat /var/log/install_script.log
```

## Configuration

### Automatic Update Settings

The automatic update settings are written to `/etc/apt/apt.conf.d/20auto-upgrades`. Here's what a typical configuration looks like:

```bash
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
```

### Unattended Upgrades Configuration

The settings for `unattended-upgrades` are written to `/etc/apt/apt.conf.d/50unattended-upgrades`. A typical configuration includes:

```bash
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
    "${distro_id}:${distro_codename}-updates";
};
Unattended-Upgrade::Package-Blacklist {
};
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
```

### Cron Job

The script sets a cron job to execute `unattended-upgrade` every 3 days. You can view this cron job by running:

```bash
crontab -l
```

## Troubleshooting

- **Permission Denied**: Ensure you are running the script as the `root` user.
- **Command Not Found**: Make sure all prerequisites are installed and your `$PATH` is correctly set.
- **Logs Not Generating**: Check the script's writing permissions for `/var/log/`.

## Contributing

Feel free to fork this repository and submit pull requests to contribute to or enhance this script.

## License

This script is released under the MIT License. See the `LICENSE` file for more details
