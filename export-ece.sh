#!/bin/bash
# ECE (Eusufzai Common Environment) Config Exporter
# By Ayaan Eusufzai

set -e  # Exit immediately if a command fails

GITHUB_USER="2048hertz"
REPO_NAME="ece"
VERSION="1.0"
EXPORT_DIR="ece-$VERSION"
ZIP_FILE="$EXPORT_DIR.zip"

echo "🔧 Preparing ECE configuration for release $VERSION..."

# Create the directory for packaging
rm -rf "$EXPORT_DIR"
mkdir -p "$EXPORT_DIR"

# Copy XFCE configuration files
echo "📂 Copying XFCE configuration..."
cp -r ~/.config/xfce4 "$EXPORT_DIR/"
cp -r ~/.config/Thunar "$EXPORT_DIR/"

# Create a zip file
echo "📦 Creating zip archive..."
rm -f "$ZIP_FILE"
zip -r "$ZIP_FILE" "$EXPORT_DIR"

echo "✅ ECE configuration has been packaged successfully!"
echo "📁 Zip file created: $ZIP_FILE"
echo ""
echo "💡 Next Steps:"
echo "1. Manually upload '$ZIP_FILE' to your GitHub repo ($REPO_NAME)."
echo "2. Go to GitHub → Releases → Create a new release."
echo "3. Tag it as '$VERSION' and attach '$ZIP_FILE'."
echo "4. Save the release and you're done!"
