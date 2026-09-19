#!/bin/bash
# Builds Meridian.app from main.swift + the app HTML
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
cd "$HERE"
APP="${1:-$HERE/Meridian.app}"
NAME="Meridian"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

echo "Compiling…"
swiftc -O main.swift -o "$APP/Contents/MacOS/$NAME"

cp "$ROOT/index.html" "$APP/Contents/Resources/index.html"
[ -f icon.icns ] && cp icon.icns "$APP/Contents/Resources/icon.icns"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>$NAME</string>
  <key>CFBundleDisplayName</key><string>$NAME</string>
  <key>CFBundleExecutable</key><string>$NAME</string>
  <key>CFBundleIdentifier</key><string>com.wallasace.meridian</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSHumanReadableCopyright</key><string>Copyright © 2026 Wallace Ferreira de Abreu. Licensed under PolyForm Internal Use 1.0.0.</string>
$([ -f icon.icns ] && echo "  <key>CFBundleIconFile</key><string>icon</string>")
</dict>
</plist>
PLIST

# Ad-hoc signature: avoids the "unverified app" warning on this machine.
codesign --force --deep --sign - "$APP" 2>/dev/null || echo "(warning: could not sign)"

echo "Done: $APP"
du -sh "$APP"
