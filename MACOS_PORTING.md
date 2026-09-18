# macOS Porting Guide

This document details the changes made to support macOS and provides troubleshooting tips.

## Changes Made

### 1. Dependencies (`requirements.txt`)

- Added `pyobjc-framework-Cocoa` and `pyobjc-framework-CoreServices` for macOS-specific features (optional, for future enhancements)
- Removed `tzdata` dependency from macOS (not needed; macOS has built-in IANA time zone database)
- Kept Windows-only `tzdata` via `sys_platform == "win32"` condition

### 2. Code Compatibility

The original code required **no changes** for macOS compatibility because:

- **PySide6/Qt6** works natively on macOS
- **zoneinfo** is available in Python 3.9+ on macOS without extra packages
- **Font loading** uses the bundled Noto Sans fonts (cross-platform)
- **Flag assets** are PNG images (cross-platform)
- **Window management** uses Qt-provided APIs that work on macOS
- **Settings storage** uses Qt's QSettings, which stores in `~/Library/Preferences/` on macOS (native approach)

### 3. Build & Distribution (`build_macos_app.py`)

Created a helper script to build a native macOS .app bundle:

```bash
python3 build_macos_app.py
```

This script:
- Creates a proper macOS application bundle structure
- Generates `Info.plist` with required metadata
- Creates a launcher wrapper script
- Supports optional code-signing: `python3 build_macos_app.py --sign <identity>`

## Installation Instructions

### From Source

```bash
git clone https://github.com/wallasace/world-clock.git
cd world-clock
pip install -r requirements.txt
python3 world_clock.py
```

### As a Native App Bundle

```bash
git clone https://github.com/wallasace/world-clock.git
cd world-clock
pip install -r requirements.txt
python3 build_macos_app.py
open World\ Clock.app
```

Then drag `World Clock.app` to `/Applications` for system-wide installation.

## Testing on macOS

### Manual Testing

1. **Install dependencies:**
   ```bash
   python3 -m pip install --upgrade pip
   python3 -m pip install -r requirements.txt
   ```

2. **Run the app:**
   ```bash
   python3 world_clock.py
   ```

3. **Verify functionality:**
   - Window appears and displays correctly
   - Clock updates every second
   - Country picker works with search
   - Settings persist between launches
   - Time zone calculations are accurate
   - Dark mode rendering is correct

### Automated Testing

Run any existing test suite:

```bash
python3 -m pytest
```

## Troubleshooting

### "Command not found: python3"

macOS may have only Python 2 or require explicitly installed Python 3:

```bash
# Using Homebrew (install if needed: https://brew.sh)
brew install python3
python3 world_clock.py

# Or using pyenv (https://github.com/pyenv/pyenv)
pyenv install 3.11
pyenv shell 3.11
python world_clock.py
```

### "No module named 'PySide6'"

```bash
python3 -m pip install --upgrade PySide6
```

### App won't start from Finder

Check console output:

```bash
# Run from terminal to see errors
python3 world_clock.py
```

If building the .app bundle, verify the launcher script has executable permissions:

```bash
chmod +x World\ Clock.app/Contents/MacOS/"World Clock"
```

### Time zone not updating correctly

Ensure `zoneinfo` data is current:

```bash
python3 -c "from zoneinfo import ZoneInfo; print(ZoneInfo('America/Sao_Paulo'))"
```

On older macOS versions, you may need:

```bash
python3 -m pip install --upgrade tzdata
```

### App appears blurry on Retina display

This is usually Qt rendering correctly. If needed, ensure PySide6 is built for your architecture:

```bash
python3 -c "import PySide6; print(PySide6.__version__)"
```

For Apple Silicon Macs, ensure you're using Python 3.9+ compiled for ARM64:

```bash
python3 -c "import platform; print(platform.machine())"
# Should print: arm64
```

## macOS-Specific Behavior

### Settings Storage

On macOS, user settings are stored in:
```
~/Library/Preferences/com.aceaswall.WorldClock.plist
```

To reset settings:

```bash
defaults delete com.aceaswall.WorldClock
```

### Window Behavior

- The window is **frameless** (no title bar) as designed
- Use **click-and-drag** on any empty area to move the window
- Use **Command+Q** or the **×** button to close (standard macOS behavior)

### Dark Mode

The app respects the system's dark mode setting automatically through Qt.

### Accessibility

The app supports keyboard navigation and screen readers through Qt's accessibility framework.

## Distribution

### Creating a Signed, Distributable App

```bash
# Build the app
python3 build_macos_app.py

# Code-sign it (requires a valid identity)
python3 build_macos_app.py --sign "Developer ID Application"

# Verify code signature
codesign -v --deep World\ Clock.app

# Create a DMG for distribution
hdiutil create -volname "World Clock" -srcfolder . -ov -format UDZO -imagekey zlib-level=9 world-clock.dmg
```

### Publishing to macOS App Store (Future)

Additional steps would be needed to submit to the Mac App Store, including:
- Sandboxing configuration
- Entitlements file
- App Review guidelines compliance
- Provisioning profiles

Contact Anthropic or macOS development guidelines for more details.

## Platform Comparison

| Feature | Linux (KDE) | Windows 11 | macOS |
|---------|------------|-----------|-------|
| Installation | `pip install -r requirements.txt` | Same | Same |
| Launcher | `.desktop` file | Shortcut wizard | Automator or `build_macos_app.py` |
| Settings | `~/.config/` | `%APPDATA%/` | `~/Library/Preferences/` |
| Time zones | System IANA database | `tzdata` package | System IANA database |
| Font bundling | Yes (consistency) | Yes (Windows fallback) | Yes (consistency) |
| Code signing | N/A | Windows Defender SmartScreen | Code signing (recommended) |

## Known Limitations

- The app icon is not yet customized (uses default app icon)
- No native menu bar integration (the window itself has a close button)
- No notification center integration (would require separate implementation)

These features can be added in future versions using `pyobjc` for native macOS APIs.

## Contributing

When making changes that affect macOS support:

1. Test on a macOS machine (or use cloud macOS environments like MacStadium)
2. Verify the build script still works
3. Update this guide if behavior changes
4. Test both direct execution and `.app` bundle running

## References

- [Qt for Python (PySide6) on macOS](https://doc.qt.io/qtforpython/)
- [Python on macOS](https://docs.python.org/3/library/intro.html)
- [macOS App Development Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
