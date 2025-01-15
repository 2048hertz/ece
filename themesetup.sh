#!/bin/bash
# Written by Ayaan Eusufzai

# Clone the Orchis theme repository
sudo git clone https://github.com/vinceliuice/Orchis-theme.git

# Get variables for xfconf-query
read -p "Enter your current username: " baseuser

# Install necessary dependencies for building the theme
sudo dnf install gtk-murrine-engine gtk2-engines sassc

# Navigate to the cloned directory
cd Orchis-theme

# Run the installation script
./install.sh --tweaks solid

# Add the Numix PPA and install the Numix Square icon theme
sudo dnf install numix-icon-theme-square

# Use xfconf-query to change settings
sudo -u $baseuser xfconf-query -c xsettings -p /Net/ThemeName -s "Orchis-Dark"
sudo -u $baseuser xfconf-query -c xsettings -p /Net/IconThemeName -s "Numix-Square"

echo "Please reboot the system to apply all changes"