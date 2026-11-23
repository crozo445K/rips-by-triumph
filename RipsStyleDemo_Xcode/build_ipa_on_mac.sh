#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/RipsStyleDemo"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "ERROR: Xcode command-line tools are required. Run this script on a Mac with Xcode installed."
  exit 1
fi

TEAM_ID="${TEAM_ID:-}"
if [[ -z "$TEAM_ID" ]]; then
  echo "Enter your Apple Developer Team ID (find it in Xcode > Settings > Accounts > your account):"
  read -r TEAM_ID
fi

ARCHIVE="$PWD/build/RipsStyleDemo.xcarchive"
EXPORT="$PWD/build/ipa"
mkdir -p "$PWD/build"

xcodebuild \
  -project RipsStyleDemo.xcodeproj \
  -scheme RipsStyleDemo \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE" \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  PRODUCT_BUNDLE_IDENTIFIER="com.example.RipsStyleDemo" \
  archive

cat > "$PWD/build/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>method</key><string>development</string>
<key>signingStyle</key><string>automatic</string>
<key>teamID</key><string>$TEAM_ID</string>
<key>compileBitcode</key><false/>
</dict></plist>
PLIST

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportPath "$EXPORT" \
  -exportOptionsPlist "$PWD/build/ExportOptions.plist" \
  -allowProvisioningUpdates

echo "IPA created at: $EXPORT/RipsStyleDemo.ipa"
