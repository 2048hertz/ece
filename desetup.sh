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

# Install the FreeSans font
echo_message "Installing the FreeSans font..."
font_url="https://ftp.gnu.org/gnu/freefont/freefont-ttf-20120503.zip"
temp_dir=$(mktemp -d)
curl -L "$font_url" -o "$temp_dir/freefont.zip"
unzip "$temp_dir/freefont.zip" -d "$temp_dir"
mkdir -p ~/.local/share/fonts
cp "$temp_dir/freefont-ttf-20120503/FreeSans.ttf" ~/.local/share/fonts/
fc-cache -fv ~/.local/share/fonts
rm -rf "$temp_dir"

# Apply the Orchis GTK theme and Numix Square icon theme
echo_message "Applying the Orchis GTK theme and Numix Square icon theme..."
xfconf-query -c xsettings -p /Net/ThemeName -s "Orchis-Dark"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Numix-Square"

# Set the default font to FreeSans
echo_message "Setting the default font to FreeSans..."
xfconf-query -c xsettings -p /Gtk/FontName -s "FreeSans 10"

# Set the XFWM4 (window manager) theme to match Orchis
echo_message "Setting the XFWM4 theme to match Orchis..."
xfconf-query -c xfwm4 -p /general/theme -s "Orchis-Dark"

# Customize the Applications Menu icon
echo_message "Customizing the Applications Menu icon..."
# Define the source and destination paths
SOURCE_DIR=~/ece
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

# Notify the user to reboot
echo_message "Installation complete. Please reboot your system to apply all changes."
