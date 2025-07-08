#!/bin/bash
# Run this manually after container launches to install security tools
# This keeps launch time fast while giving you full security setup

echo "Installing ClamAV and Falco security tools..."
echo "This will take a few minutes but only needs to be done once."

# Update system
apt-get update

# Install ClamAV
echo "Installing ClamAV..."
apt-get install -y clamav clamav-daemon
freshclam

# Install Falco dependencies
echo "Installing Falco dependencies..."
apt-get install -y curl gnupg2

# Add Falco repository
echo "Adding Falco repository..."
curl -s https://falco.org/repo/falcosecurity-packages.asc | apt-key add -
echo "deb https://download.falco.org/packages/deb stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list

# Update and install Falco
echo "Installing Falco..."
apt-get update
apt-get install -y falco

# Create log directories
mkdir -p /var/log/clamav
mkdir -p /var/log/falco

# Setup ClamAV cron jobs
echo "Setting up automated scanning..."
echo "0 2 * * * freshclam --quiet && clamscan -r /home --quiet --infected --log=/var/log/clamav/daily-scan.log" >> /var/spool/cron/crontabs/root
echo "0 */6 * * * freshclam --quiet" >> /var/spool/cron/crontabs/root

# Enable and start Falco
echo "Starting Falco..."
systemctl enable falco
systemctl start falco

echo ""
echo "✅ Installation complete!"
echo ""
echo "ClamAV Commands:"
echo "  clamscan -r /path/to/scan    # Manual scan"
echo "  tail -f /var/log/clamav/daily-scan.log  # View scan results"
echo ""
echo "Falco Commands:"
echo "  systemctl status falco       # Check status"
echo "  journalctl -u falco -f      # View real-time alerts"
echo "  tail -f /var/log/falco/falco.log  # View logs"
echo ""
echo "Both tools are now running and monitoring your system!"