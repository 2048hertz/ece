#!/bin/bash
# By Ayaan Eusufzai
# This is just a tool for AdaOS developers to package our tailored version of XFCE, now called ECE (Eusufzai Common Environment). 
# This replaces the old method of customizing XFCE with a bash script.
set -e  # Exit if any command fails

ECE_NAME="ece"
VERSION="1.0"
RELEASE="1"

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
mkdir -p ece-config
cp -r ~/.config/xfce4 ece-config/
cp -r ~/.config/Thunar ece-config/

echo "📦 Packaging XFCE settings..."
tar -czvf $SOURCEDIR/ece-settings.tar.gz -C ece-config .

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
Source0:        ece-settings.tar.gz

%description
ECE (Eusufzai Common Environment) is a customized XFCE desktop environment tailored for usability and aesthetics on AdaOS.

%prep
%setup -q

%install
mkdir -p %{buildroot}/etc/skel/.config/
cp -r xfce4 %{buildroot}/etc/skel/.config/
cp -r Thunar %{buildroot}/etc/skel/.config/

%files
/etc/skel/.config/xfce4
/etc/skel/.config/Thunar

%changelog
* Mon Feb 11 2025 Ayaan Eusufzai <2048megahertz@proton.me> - 1.0-1
- Initial release of ECE (Eusufzai Common Environment) customized desktop.
EOF

echo "🛠️ Building the RPM package..."
rpmbuild -bb $SPECFILE

echo "📥 Installing ECE..."
sudo dnf install -y ~/rpmbuild/RPMS/noarch/$ECE_NAME-$VERSION-$RELEASE.noarch.rpm

echo "✅ ECE (Eusufzai Common Environment) has been installed successfully on AdaOS!"
echo "💡 New users will automatically receive the ECE desktop configuration."
