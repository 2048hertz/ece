#!/bin/bash
# Written by Ayaan Eusufzai

# Function to display messages
function echo_message() {
    echo -e "\n\e[1;32m$1\e[0m\n"
}

# Ensure the script is run as a regular user
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root or using sudo."
    exit 1
fi

# Update system packages
echo_message "Updating system packages..."
sudo dnf update -y

# Install necessary dependencies
echo_message "Installing necessary dependencies..."
sudo dnf install -y git gtk-murrine-engine sassc unzip

# Clone and install the Orchis GTK theme
echo_message "Cloning and installing the Orchis GTK theme..."
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme
./install.sh --tweaks solid
cd ..
rm -rf Orchis-theme

# Clone and install the Numix Square icon theme
echo_message "Cloning and installing the Numix Square icon theme..."
git clone https://github.com/numixproject/numix-icon-theme-square.git
mkdir -p ~/.icons
cp -r numix-icon-theme-square/Numix-Square ~/.icons/
rm -rf numix-icon-theme-square

# Apply the Orchis GTK theme and Numix Square icon theme
echo_message "Applying the Orchis GTK theme and Numix Square icon theme..."
xfconf-query -c xsettings -p /Net/ThemeName -s "Orchis-Dark"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Numix-Square"

# Notify the user to reboot
echo_message "Installation complete. Please reboot your system to apply all changes."
