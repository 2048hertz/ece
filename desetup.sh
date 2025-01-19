#!/bin/bash
# Written by Ayaan Eusufzai

# Theme setup
bash ~/adaos-xfce-main/themesetup.sh

# Get variables for xfconf-query
read -p "Enter your current username: " baseuser

# Define font download URL
font_url="https://github.com/ifvictr/helvetica-neue/archive/refs/heads/master.zip"
temp_dir=$(mktemp -d)

# Download and unzip the font
curl -L "$font_url" -o "$temp_dir/font.zip"
unzip "$temp_dir/font.zip" -d "$temp_dir"

# Create local fonts directory if it doesn't exist
mkdir -p ~/.local/share/fonts

# Copy fonts to the local directory
cp -r "$temp_dir/helvetica-neue-master/"* ~/.local/share/fonts/

# Update font cache
fc-cache -fv ~/.local/share/fonts

echo "Fonts installed successfully."

# THE REBRAND

# Define the new contents
new_contents="Gevox\n\nSoftware Team - 2048megahertz@proton.me\n\nBugs should be reported at our GitHub - https://github.com/2048hertz/AdaOS/"

# Write the new contents to the user's local vendorinfo file
mkdir -p ~/.local/share/xfce4
echo -e "$new_contents" > ~/.local/share/xfce4/vendorinfo
echo "Contents of ~/.local/share/xfce4/vendorinfo have been updated."

# Define the source and destination paths
SOURCE_DIR=~/adaos-xfce-main
DEST_DIR=~/.local/share/icons/hicolor

# Create necessary directories
mkdir -p "$DEST_DIR/16x16/apps"
mkdir -p "$DEST_DIR/24x24/apps"
mkdir -p "$DEST_DIR/32x32/apps"
mkdir -p "$DEST_DIR/48x48/apps"

# Replace the icons for each specified size
cp "$SOURCE_DIR/16x16/org.xfce.panel.applicationsmenu.png" "$DEST_DIR/16x16/apps/org.xfce.panel.applicationsmenu.png"
cp "$SOURCE_DIR/24x24/org.xfce.panel.applicationsmenu.png" "$DEST_DIR/24x24/apps/org.xfce.panel.applicationsmenu.png"
cp "$SOURCE_DIR/32x32/org.xfce.panel.applicationsmenu.png" "$DEST_DIR/32x32/apps/org.xfce.panel.applicationsmenu.png"
cp "$SOURCE_DIR/48x48/org.xfce.panel.applicationsmenu.png" "$DEST_DIR/48x48/apps/org.xfce.panel.applicationsmenu.png"

echo "Icon replacement completed."

# Function to set XFCE window manager button layout
set_button_layout() {
    xfconf-query -c xfwm4 -p /general/button_layout -s "SH|MC"
    xfconf-query -c xfwm4 -p /general/title_alignment -s "center"
    echo "Button layout changed to SH|MC"
}

# Function to customize the top panel
top_panel() {
    xfconf-query --create -c xfce4-panel -p /plugins/plugin-1/show-button-title -s "false"
    xfconf-query --create -c xfce4-panel -p /plugins/plugin-14/button-title -s 3
    xfconf-query --create -c xfce4-panel -p /plugins/plugin-14/custom-title -s " Session Menu "
}

# Apply XFCE customizations
set_button_layout
top_panel

echo "Default XFCE configuration updated successfully."

# Clean up temporary directory
rm -rf "$temp_dir"

echo "The XFCE customization script has been executed successfully."

