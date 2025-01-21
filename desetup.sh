#!/bin/bash
# Written by Ayaan Eusufzai
# Merged script to:
#  - Update system & install dependencies
#  - Install Orchis & Numix Square
#  - Apply Orchis theme, Numix icons, Cantarell fonts
#  - Set window manager theme & button layout
#  - Copy custom Applications Menu icons
#  - Remove default Applications Menu plugin
#  - Install & add Whisker Menu plugin
#  - Rename Session Menu plugin (plugin-14) to "Session Menu" (appearance tweaks)

###############################################################################
# 1. Helper function to display messages
###############################################################################
function echo_message() {
    echo -e "\n\e[1;32m$1\e[0m\n"
}

###############################################################################
# 2. Ensure the script is NOT run as root
###############################################################################
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root or using sudo."
    exit 1
fi

###############################################################################
# 3. Update system packages
###############################################################################
echo_message "Updating system packages..."
sudo dnf update -y

###############################################################################
# 4. Install necessary dependencies
###############################################################################
echo_message "Installing necessary dependencies..."
sudo dnf install -y \
    git \
    gtk-murrine-engine \
    sassc \
    unzip \
    xfce4-whiskermenu-plugin \
    cantarell-fonts

###############################################################################
# 5. Clone and install the Orchis GTK theme
###############################################################################
echo_message "Cloning and installing the Orchis GTK theme..."
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme
./install.sh --tweaks solid
cd ..
rm -rf Orchis-theme

###############################################################################
# 6. Clone and install the Numix Square icon theme
###############################################################################
echo_message "Cloning and installing the Numix Square icon theme..."
git clone https://github.com/numixproject/numix-icon-theme-square.git
mkdir -p ~/.icons
cp -r numix-icon-theme-square/Numix-Square ~/.icons/
rm -rf numix-icon-theme-square

###############################################################################
# 7. Apply the Orchis GTK theme and Numix Square icon theme
###############################################################################
echo_message "Applying the Orchis GTK theme and Numix Square icon theme..."
xfconf-query -c xsettings -p /Net/ThemeName -s "Orchis-Dark"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Numix-Square"

###############################################################################
# 8. Set Cantarell Regular as the default font
###############################################################################
echo_message "Setting Cantarell Regular as the default font..."
xfconf-query -c xsettings -p /Gtk/FontName -s "Cantarell Regular 10"

###############################################################################
# 9. Set the XFWM4 (window manager) theme to match Orchis
###############################################################################
echo_message "Setting the XFWM4 theme to match Orchis..."
xfconf-query -c xfwm4 -p /general/theme -s "Orchis-Dark"

###############################################################################
# 10. Customize the Applications Menu icon
###############################################################################
echo_message "Customizing the Applications Menu icon..."

SOURCE_DIR=~/adaos-xfce-main
DEST_DIR=~/.local/share/icons/hicolor

# Create necessary directories and copy icons
mkdir -p "$DEST_DIR/16x16/apps"
mkdir -p "$DEST_DIR/24x24/apps"
mkdir -p "$DEST_DIR/32x32/apps"
mkdir -p "$DEST_DIR/48x48/apps"

cp "$SOURCE_DIR/16x16/org.xfce.panel.applicationsmenu.png" "$DEST_DIR/16x16/apps/org.xfce.panel.applicationsmenu.png"
cp "$SOURCE_DIR/24x24/org.xfce.panel.applicationsmenu.png" "$DEST_DIR/24x24/apps/org.xfce.panel.applicationsmenu.png"
cp "$SOURCE_DIR/32x32/org.xfce.panel.applicationsmenu.png" "$DEST_DIR/32x32/apps/org.xfce.panel.applicationsmenu.png"
cp "$SOURCE_DIR/48x48/org.xfce.panel.applicationsmenu.png" "$DEST_DIR/48x48/apps/org.xfce.panel.applicationsmenu.png"

# Update the icon cache
gtk-update-icon-cache "$DEST_DIR"

###############################################################################
# 11. Configure panel settings
###############################################################################
echo_message "Configuring panel settings..."

# Hide the Applications Menu title (plugin-1). 
# If plugin-1 is the old menu, it will be removed anyway, but we keep the line:
xfconf-query -c xfce4-panel -p /plugins/plugin-1/show-button-title -s false

###############################################################################
# 12. Define a helper function to set properties
###############################################################################
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

###############################################################################
# 13. Rename the Session Menu plugin (assumed to be plugin-14)
###############################################################################
# These lines come from your old script: set a custom title, appearance, etc.
echo_message "Renaming the Session Menu plugin (plugin-14) to 'Session Menu'..."
set_property xfce4-panel /plugins/plugin-14/button-title int 3
set_property xfce4-panel /plugins/plugin-14/custom-title string " Session Menu "
set_property xfce4-panel /plugins/plugin-14/appearance int 1

###############################################################################
# 14. Set XFCE window manager button layout (like 'SH|MC') and center title
###############################################################################
echo_message "Setting XFCE window manager button layout..."
xfconf-query -c xfwm4 -p /general/button_layout -s "SH|MC"
xfconf-query -c xfwm4 -p /general/title_alignment -s "center"

###############################################################################
# 15. (Re)Install the Whisker Menu plugin - if not installed
###############################################################################
echo_message "Ensuring Whisker Menu plugin is installed..."
sudo dnf install -y xfce4-whiskermenu-plugin

###############################################################################
# 16. Add the Whisker Menu to the panel (panel-1)
###############################################################################
echo_message "Adding the Whisker Menu to the panel..."

# Retrieve the current list of plugin IDs
plugin_ids=$(xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids)

# Generate a new unique plugin ID 
# (Naive approach: count commas in plugin_ids, + 1)
new_id=$(( $(echo "$plugin_ids" | tr -d -c ',' | wc -c) + 1 ))

# Add the Whisker Menu plugin
xfconf-query -c xfce4-panel -p /plugins/plugin-$new_id -n -t string -s whiskermenu
xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids -t int -s $new_id -a

###############################################################################
# 17. Remove the default Applications Menu from the panel
###############################################################################
echo_message "Removing the default Applications Menu from the panel..."

# Find the plugin ID of the existing Applications Menu (by plugin-type)
app_menu_id=$(
    xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids | \
    grep -o '[0-9]\+' | while read id; do
        if xfconf-query -c xfce4-panel -p /plugins/plugin-$id -v 2>/dev/null | grep -q 'applicationsmenu'; then
            echo $id
            break
        fi
    done
)

# Remove the Applications Menu plugin from the panel if found
if [ -n "$app_menu_id" ]; then
    xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids -t int -r -R -s $app_menu_id
    xfconf-query -c xfce4-panel -p /plugins/plugin-$app_menu_id -r -R
    echo "Removed old Applications Menu (plugin-$app_menu_id)."
fi

###############################################################################
# 18. Set the Whisker Menu icon to match the newly replaced Applications Menu icon
###############################################################################
echo_message "Setting Whisker Menu to use the custom Applications Menu icon..."
xfconf-query -c xfce4-panel -p /plugins/plugin-$new_id/button-icon -s "org.xfce.panel.applicationsmenu"
# Hide its text label if desired
xfconf-query -c xfce4-panel -p /plugins/plugin-$new_id/show-button-title -s false

###############################################################################
# 19. Done!
###############################################################################
echo_message "All done! 
- Orchis theme + Numix icons + Cantarell font applied.
- Default Applications Menu replaced by Whisker Menu.
- Session Menu renamed to 'Session Menu' (plugin-14).
- Window manager buttons set to SH|MC with centered titles.

You may need to log out/in or restart the panel (right-click > Panel > Restart) 
to see all changes."
