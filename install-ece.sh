#!/bin/bash
# ECE (Eusufzai Common Environment) Installer for AdaOS
# By Ayaan Eusufzai

set -e  # Exit immediately if any command fails

GITHUB_USER="2048hertz"
REPO_NAME="ece"
VERSION="1.0"
ZIP_URL="https://github.com/$GITHUB_USER/$REPO_NAME/archive/refs/tags/$VERSION.zip"
TEMP_DIR="/tmp/ece-install"
INSTALL_DIR="/etc/skel/.config"

echo "🔧 Installing ECE (Eusufzai Common Environment) on AdaOS..."

# Install required dependencies
echo "📦 Installing necessary tools..."
sudo dnf install -y wget unzip xfce4 xfce4-panel xfwm4 xfce4-settings arc-theme papirus-icon-theme

# Create temporary directory
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Download the latest ECE configuration from GitHub
echo "🌐 Downloading ECE configuration from GitHub..."
wget -O "$TEMP_DIR/ece.zip" "$ZIP_URL"

# Extract the downloaded configuration
echo "📂 Extracting configuration..."
unzip -q "$TEMP_DIR/ece.zip" -d "$TEMP_DIR"

# Find extracted folder (since GitHub zips it as ece-1.0)
EXTRACTED_DIR=$(find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)

# Ensure the extracted directory exists
if [[ ! -d "$EXTRACTED_DIR" ]]; then
    echo "❌ Error: Failed to find extracted configuration folder!"
    exit 1
fi

# Backup existing XFCE settings in /etc/skel
if [[ -d "$INSTALL_DIR/xfce4" || -d "$INSTALL_DIR/Thunar" ]]; then
    BACKUP_DIR="/etc/skel/.config-backup-$(date +%Y%m%d%H%M%S)"
    echo "📂 Backing up existing XFCE settings to $BACKUP_DIR..."
    sudo mkdir -p "$BACKUP_DIR"
    sudo mv "$INSTALL_DIR/xfce4" "$BACKUP_DIR/" 2>/dev/null || true
    sudo mv "$INSTALL_DIR/Thunar" "$BACKUP_DIR/" 2>/dev/null || true
fi

# Copy the new configuration to /etc/skel
echo "📁 Applying ECE configurations..."
sudo mkdir -p "$INSTALL_DIR"
sudo cp -r "$EXTRACTED_DIR/xfce4" "$INSTALL_DIR/" 2>/dev/null || echo "No xfce4 config found."
sudo cp -r "$EXTRACTED_DIR/Thunar" "$INSTALL_DIR/" 2>/dev/null || echo "No Thunar config found."

# Set correct permissions
echo "🔧 Fixing permissions..."
sudo chown -R root:root "$INSTALL_DIR/xfce4" "$INSTALL_DIR/Thunar" 2>/dev/null || true
sudo chmod -R 755 "$INSTALL_DIR/xfce4" "$INSTALL_DIR/Thunar" 2>/dev/null || true

# Clean up temporary files
rm -rf "$TEMP_DIR"

echo "✅ ECE (Eusufzai Common Environment) has been successfully installed!"
echo "💡 New users will automatically receive the ECE desktop configuration."
