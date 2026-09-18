#!/usr/bin/env bash
# Installs Meridian for the current user on Linux: no root, no build step.
#   ./desktop/linux/install.sh            install
#   ./desktop/linux/install.sh --uninstall
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
APPDIR="$HOME/.local/share/meridian"
DESKTOP="$HOME/.local/share/applications/meridian.desktop"
ICONDIR="$HOME/.local/share/icons/hicolor/512x512/apps"

if [ "${1:-}" = "--uninstall" ]; then
  rm -rf "$APPDIR" "$DESKTOP" "$ICONDIR/meridian.png"
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
  echo "Meridian removed."
  exit 0
fi

echo "Checking dependencies..."
missing=""
python3 - <<'PY' 2>/dev/null || missing="python3-gi / gir1.2-webkit2-4.1"
import gi
gi.require_version("Gtk", "3.0")
try:
    gi.require_version("WebKit2", "4.1")
except ValueError:
    gi.require_version("WebKit2", "4.0")
from gi.repository import Gtk, WebKit2
PY

if [ -n "$missing" ]; then
  echo "Missing: $missing" >&2
  echo "" >&2
  echo "  Debian/Ubuntu  sudo apt install python3-gi gir1.2-webkit2-4.1" >&2
  echo "  Fedora         sudo dnf install python3-gobject webkit2gtk4.1" >&2
  echo "  Arch           sudo pacman -S python-gobject webkit2gtk-4.1" >&2
  exit 1
fi

mkdir -p "$APPDIR" "$ICONDIR" "$(dirname "$DESKTOP")"
install -m 755 "$HERE/meridian.py" "$APPDIR/meridian.py"
install -m 644 "$ROOT/index.html"  "$APPDIR/index.html"
[ -f "$ROOT/icons/icon-512.png" ] && install -m 644 "$ROOT/icons/icon-512.png" "$ICONDIR/meridian.png"
[ -f "$ROOT/icons/icon-512.png" ] && install -m 644 "$ROOT/icons/icon-512.png" "$APPDIR/meridian.png"

cat > "$DESKTOP" <<EOF
[Desktop Entry]
Type=Application
Name=Meridian
GenericName=World Clock
Comment=Two destinations side by side, with live local time
Exec=python3 $APPDIR/meridian.py
Icon=meridian
Terminal=false
Categories=Utility;Clock;
StartupWMClass=meridian
EOF
chmod 644 "$DESKTOP"

update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

echo "Installed. Look for Meridian in your application menu,"
echo "or run it directly:  python3 $APPDIR/meridian.py"
