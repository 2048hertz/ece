#!/bin/bash
# ECE (Eusufzai Common Environment) Installer for AdaOS
# By Ayaan Eusufzai

set -e  # Exit immediately if a command fails

GITHUB_USER="2048hertz"
REPO_NAME="ece"
VERSION="1.0"
ZIP_URL="https://github.com/$GITHUB_USER/$REPO_NAME/releases/download/$VERSION/ece.zip"
TEMP_DIR="/tmp/ece-install"
INSTALL_DIR="/etc/skel/.config"
USER_CONFIG_DIR="$HOME/.config"

echo_message() {
    echo -e "\n$1...\n"
}

# Step 1: Update System and Install Dependencies
echo_message "Updating system packages"
sudo dnf update -y

echo_message "Installing necessary dependencies"
sudo dnf install -y git gtk-murrine-engine sassc unzip

# Step 2: Install Orchis GTK Theme
echo_message "Cloning and installing the Orchis GTK theme"
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme
./install.sh --tweaks solid
cd ..
rm -rf Orchis-theme

# Step 3: Install Numix Square Icon Theme
echo_message "Cloning and installing the Numix Square icon theme"
git clone https://github.com/numixproject/numix-icon-theme-square.git
mkdir -p ~/.icons
cp -r numix-icon-theme-square/Numix-Square ~/.icons/
rm -rf numix-icon-theme-square

# Step 4: Download ECE XFCE Configuration from GitHub Releases
echo_message "Downloading ECE XFCE configuration from GitHub Releases"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

wget -O "$TEMP_DIR/ece.zip" "$ZIP_URL"

# Step 5: Extract the Configuration
echo_message "Extracting ECE configuration"
unzip -q "$TEMP_DIR/ece.zip" -d "$TEMP_DIR"

# Ensure extracted folder contains xfce4 and Thunar
if [[ ! -d "$TEMP_DIR/xfce4" || ! -d "$TEMP_DIR/Thunar" ]]; then
    echo "Error: XFCE configuration (xfce4/Thunar) not found in the downloaded zip!"
    exit 1
fi

# Step 6: Backup Existing Configurations
BACKUP_DIR="$HOME/ece-backup-$(date +%Y%m%d%H%M%S)"
echo_message "Backing up existing XFCE configurations to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
mv "$USER_CONFIG_DIR/xfce4" "$BACKUP_DIR/" 2>/dev/null || echo "No previous XFCE config found."
mv "$USER_CONFIG_DIR/Thunar" "$BACKUP_DIR/" 2>/dev/null || echo "No previous Thunar config found."

# Step 7: Copy Configurations to the Current User
echo_message "Applying XFCE configuration for the current user"
mkdir -p "$USER_CONFIG_DIR"
cp -r "$TEMP_DIR/xfce4" "$USER_CONFIG_DIR/"
cp -r "$TEMP_DIR/Thunar" "$USER_CONFIG_DIR/"

# Step 8: Copy Configurations to /etc/skel for New Users
echo_message "Applying XFCE configuration to /etc/skel for new users"
sudo mkdir -p "$INSTALL_DIR"
sudo cp -r "$TEMP_DIR/xfce4" "$INSTALL_DIR/"
sudo cp -r "$TEMP_DIR/Thunar" "$INSTALL_DIR/"

# Step 9: Fix Permissions
echo_message "Fixing permissions"
sudo chown -R root:root "$INSTALL_DIR"
sudo chmod -R 755 "$INSTALL_DIR"

chown -R $USER:$USER "$USER_CONFIG_DIR"

# Step 10: Clean Up
rm -rf "$TEMP_DIR"

echo_message "ECE installation complete"
echo "Numix icons, Orchis theme, and XFCE configurations have been applied."
echo "Log out and log back in to see the changes."

