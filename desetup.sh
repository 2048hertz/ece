#!/bin/bash
# Written by Ayaan Eusufzai

# Theme setup
bash /usr/bin/adaos-xfce-main/themesetup.sh

# Get variables for xfconf-query
read -p "Enter your current username: " baseuser

# Define font download URL
font_url="https://github.com/ifvictr/helvetica-neue/archive/refs/heads/master.zip"
temp_dir=$(mktemp -d)

# Top and bottom panel customizations have been removed due to issues with xfce configuration through bash

# THE REBRAND

# Define the new contents
new_contents="Gevox\n\nSoftware Team - 2048megahertz@proton.me\n\nBugs should be reported at our github - https://github.com/2048hertz/AdaOS/"

# Write the new contents to the file
echo "$new_contents" | sudo tee /usr/share/xfce4/vendorinfo > /dev/null
echo "Contents of /usr/share/xfce4/vendorinfo have been updated."

# Backup the original /etc/os-release file
sudo cp /etc/os-release /etc/os-release.bak

# Use sed to replace the required fields in /etc/os-release
sudo sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="Ada Operating System V1"/' /etc/os-release
sudo sed -i 's/^NAME=.*/NAME="AdaOS"/' /etc/os-release
sudo sed -i 's/^VERSION_ID=.*/VERSION_ID="One (Teddy Bear)"/' /etc/os-release
sudo sed -i 's/^VERSION_CODENAME=.*/VERSION_CODENAME=teddybear/' /etc/os-release
sudo sed -i 's/^ID=.*/ID=adaos/' /etc/os-release

echo "Changes applied to /etc/os-release:"
cat /etc/os-release

# Define the source and destination paths
SOURCE_DIR="/usr/bin/adaos-xfce-main"
DEST_DIR="/usr/share/icons/hicolor"

# Replace the icons for each specified size
sudo cp "$SOURCE_DIR/16x16/org.xfce.panel.applicationsmenu.png" "$DEST_DIR/16x16/apps/org.xfce.panel.applicationsmenu.png"
sudo cp "$SOURCE_DIR/24x24/org.xfce.panel.applicationsmenu.png" "$DEST_DIR/24x24/apps/org.xfce.panel.applicationsmenu.png"
sudo cp "$SOURCE_DIR/32x32/org.xfce.panel.applicationsmenu.png" "$DEST_DIR/32x32/apps/org.xfce.panel.applicationsmenu.png"
sudo cp "$SOURCE_DIR/48x48/org.xfce.panel.applicationsmenu.png" "$DEST_DIR/48x48/apps/org.xfce.panel.applicationsmenu.png"

echo "Icon replacement completed."

# END OF THE REBRAND

# START OF WALLPAPER CHANGE

# INCOMPLETE

# END OF WALLPAPER CHANGE

# Function to set XFCE window manager button layout
set_button_layout() {
    sudo -u $baseuser xfconf-query -c xfwm4 -p /general/button_layout -s "SH|MC"
    sudo -u $baseuser xfconf-query -c xfwm4 -p /general/title_alignment -s "center"
    echo "Button layout changed to SH|MC"
}

top_panel() {
    sudo -u $baseuser xfconf-query --create -c xfce4-panel -p /plugins/plugin-1/show-button-title -s "false"
    sudo -u $baseuser xfconf-query --create -c xfce4-panel -p /plugins/plugin-14/button-title -s 3
    sudo -u $baseuser xfconf-query --create -c xfce4-panel -p /plugins/plugin-14/custom-title -s " Session Menu "
}

# Apply XFCE customizations
# Top and bottom panel customizations have been removed due to issues with xfce configuration through bash
set_button_layout
top_panel

echo "Default XFCE configuration updated successfully."


# Define the path to the setup script
setup_script="/usr/bin/desetup.sh"

# Define the line to add to adduser.conf
line_to_add="ADDUSER_POST_CREATE_SCRIPT=$setup_script"

# Use sed to insert the line at line number 98 in adduser.conf
sudo sed -i "98i$line_to_add" /etc/adduser.conf

echo "Setup script added to adduser.conf at line 98."

# Clean up temporary directory
rm -rf "$temp_dir"

echo "The XFCE customization script has been executed."
