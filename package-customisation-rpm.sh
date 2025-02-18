#!/bin/bash
# By Ayaan Eusufzai
# This script packages the Eusufzai Common Environment (ECE) for AdaOS into an RPM.
# It replaces the previous method of customizing XFCE with a bash script.

set -e  # Exit immediately if a command exits with a non-zero status.

ECE_NAME="ece"
VERSION="1.0"
RELEASE="1"
EMAIL="2048megahertz@proton.me"
FULLNAME="Ayaan Eusufzai"

echo "🔧 Setting up ECE RPM Build Environment for AdaOS..."

# Install required tools if not installed
sudo dnf install -y rpm-build rpmdevtools dnf-plugins-core

# Setup RPM build directories
rpmdev-setuptree

# Define paths
BUILDROOT=~/rpmbuild/BUILDROOT
SPECFILE=~/rpmbuild/SPECS/$ECE_NAME.spec
SOURCEDIR=~/rpmbuild/SOURCES

# Create source directory
mkdir -p $SOURCEDIR
mkdir -p $BUILDROOT/etc/skel/.config/

echo "📂 Backing up current XFCE settings..."
CONFIG_DIR="ece-config"
mkdir -p $CONFIG_DIR
cp -r ~/.config/xfce4 $CONFIG_DIR/
cp -r ~/.config/Thunar $CONFIG_DIR/

echo "📦 Packaging XFCE settings..."
tar -czvf $SOURCEDIR/ece-settings.tar.gz -C $CONFIG_DIR .

echo "📝 Writing RPM spec file..."
cat <<EOF > $SPECFILE
Name:           $ECE_NAME
Version:        $VERSION
Release:        $RELEASE%{?dist}
Summary:        Eusufzai Common Environment (ECE) - Customized XFCE for AdaOS
License:        GPL
Group:          User Interface/Desktops
Requires:       xfce4, xfce4-panel, xfwm4, xfce4-settings, arc-theme, papirus-icon-theme
BuildArch:      noarch
Source0:        %{name}-settings.tar.gz

%description
ECE (Eusufzai Common Environment) is a customized XFCE desktop environment tailored for usability and aesthetics on AdaOS.

%prep
%setup -q -n $CONFIG_DIR

%install
mkdir -p %{buildroot}/etc/skel/.config/
cp -r xfce4 %{buildroot}/etc/skel/.config/
cp -r Thunar %{buildroot}/etc/skel/.config/

%files
%dir /etc/skel/.config/xfce4
%dir /etc/skel/.config/Thunar

%changelog
* Tue Feb 18 2025 $FULLNAME <$EMAIL> - $VERSION-$RELEASE
- Initial release of ECE (Eusufzai Common Environment) customized desktop.
EOF

echo "🛠️ Building the RPM package..."
rpmbuild -bb $SPECFILE

echo "📥 Installing ECE..."
sudo dnf install -y ~/rpmbuild/RPMS/noarch/$ECE_NAME-$VERSION-$RELEASE.noarch.rpm

echo "✅ ECE (Eusufzai Common Environment) has been installed successfully on AdaOS!"
echo "💡 New users will automatically receive the ECE desktop configuration."
