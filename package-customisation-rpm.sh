#!/bin/bash
# By Ayaan Eusufzai
# This is just a tool for AdaOS developers to package our tailored version of XFCE, this is supposed to be a new solution to replace the old one of customising XFCE with a bash script.
set -e  # Exit if any command fails

ADA_NAME="ada-xfce"
VERSION="1.0"
RELEASE="1"

echo "🔧 Setting up Ada-XFCE RPM Build Environment for AdaOS..."

# Install required tools if not installed
sudo dnf install -y rpm-build rpmdevtools dnf-plugins-core

# Setup RPM build directories
rpmdev-setuptree

# Define paths
BUILDROOT=~/rpmbuild/BUILDROOT
SPECFILE=~/rpmbuild/SPECS/$ADA_NAME.spec
SOURCEDIR=~/rpmbuild/SOURCES

# Create source directory
mkdir -p $SOURCEDIR
mkdir -p $BUILDROOT/etc/skel/.config/

echo "📂 Backing up current XFCE settings..."
mkdir -p ada-xfce-config
cp -r ~/.config/xfce4 ada-xfce-config/
cp -r ~/.config/Thunar ada-xfce-config/

echo "📦 Packaging XFCE settings..."
tar -czvf $SOURCEDIR/ada-xfce-settings.tar.gz -C ada-xfce-config .

echo "📝 Writing RPM spec file..."
cat <<EOF > $SPECFILE
Name:           $ADA_NAME
Version:        $VERSION
Release:        $RELEASE%{?dist}
Summary:        Customized XFCE Desktop (Ada-XFCE) for AdaOS by Ayaan Eusufzai
License:        GPL
Group:          User Interface/Desktops
Requires:       xfce4, xfce4-panel, xfwm4, xfce4-settings, arc-theme, papirus-icon-theme
BuildArch:      noarch
Source0:        ada-xfce-settings.tar.gz

%description
Ada-XFCE is a customized XFCE desktop environment tailored for usability and aesthetics on AdaOS.

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
* Mon Feb 11 2025 Your Name <your.email@example.com> - 1.0-1
- Initial release of Ada-XFCE customized desktop.
EOF

echo "🛠️ Building the RPM package..."
rpmbuild -bb $SPECFILE

echo "📥 Installing Ada-XFCE..."
sudo dnf install -y ~/rpmbuild/RPMS/noarch/$ADA_NAME-$VERSION-$RELEASE.noarch.rpm

echo "✅ Ada-XFCE has been installed successfully on AdaOS!"
echo "💡 New users will automatically receive the Ada-XFCE desktop configuration."
