#!/bin/bash
# Written by Ayaan Eusufzai

# Function to display messages
function echo_message() {
    echo -e "\n\e[1;32m$1\e[0m\n"
}

# Ensure the script is not run as root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root or using sudo."
    exit 1
fi

# Update system packages
echo_message "Updating system packages..."
sudo dnf update -y

# Install necessary dependencies
echo_message "Installing necessary dependencies..."
sudo dnf install -y git gtk-murrine-engine sassc unzip xfce4-whiskermenu-plugin

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

# Set Cantarell Regular as the default font
echo_message "Setting Cantarell Regular as the default font..."
xfconf-query -c xsettings -p /Gtk/FontName -s "Cantarell Regular 10"

# Set the XFWM4 (window manager) theme to match Orchis
echo_message "Setting the XFWM4 theme to match Orchis..."
xfconf-query -c xfwm4 -p /general/theme -s "Orchis-Dark"

# Customize the Applications Menu icon
echo_message "Customizing the Applications Menu icon..."
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
# Update the icon cache
gtk-update-icon-cache "$DEST_DIR"

# Configure panel settings
echo_message "Configuring panel settings..."

# Set the Applications Menu button to not show the title
xfconf-query -c xfce4-panel -p /plugins/plugin-1/show-button-title -s false

# Set the custom title for the Session Menu

# Function to set a property
set_property() {
    local channel=$1
    local property=$2
    local type=$3
    local value=$4

    # Check if the property exists
    if xfconf-query -c "$channel" -p "$property" &>/dev/null; then
        echo "Property $property exists. Setting its value to $value."
        xfconf-query -c "$channel" -p "$property" -t "$type" -s "$value"
    else
        echo "Property $property does not exist. Creating it with value $value."
        xfconf-query -c "$channel" -p "$property" -n -t "$type" -s "$value"
    fi
}

# Set properties for plugin-14 (Actions plugin)
set_property xfce4-panel /plugins/plugin-14/button-title int 3
set_property xfce4-panel /plugins/plugin-14/custom-title string " Session Menu "
set_property xfce4-panel /plugins/plugin-14/appearance int 1

echo "XFCE panel properties have been configured."

# Set XFCE window manager button layout
echo_message "Setting XFCE window manager button layout..."
xfconf-query -c xfwm4 -p /general/button_layout -s "SH|MC"
xfconf-query -c xfwm4 -p /general/title_alignment -s "center"

# Install the Whisker Menu plugin
echo_message "Installing the Whisker Menu plugin..."
sudo dnf install -y xfce4-whiskermenu-plugin

# Add the Whisker Menu to the panel
echo_message "Adding the Whisker Menu to the panel..."
# Retrieve the current list of plugin IDs
plugin_ids=$(xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids)

# Generate a new unique plugin ID
new_id=$(( $(echo "$plugin_ids" | tr -d -c ',' | wc -c) + 1 ))

# Add the Whisker Menu plugin
xfconf-query -c xfce4-panel -p /plugins/plugin-$new_id -n -t string -s whiskermenu
xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids -t int -s $new_id -a

# Remove the default Applications Menu from the panel
echo_message "Removing the default Applications Menu from the panel..."
# Find the plugin ID of the existing Applications Menu
app_menu_id=$(xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids | grep -o '[0-9]\+' | while read id; do
    if xfconf-query -c xfce4-panel -p /plugins/plugin-$id -v | grep -q 'applicationsmenu'; then
        echo $id
        break
    fi
done)

# Remove the Applications Menu plugin
if [ -n "$app_menu_id" ]; then
    xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids -t int -r -R -s $app_menu_id
    xfconf-query -c xfce4-panel -p /plugins/plugin-$app_menu_id -r -R
fi

# Set the Whisker Menu icon to match the original Applications Menu
::contentReference[oaicite:0]{index=0}

