#!/usr/bin/env python3
"""Build a native macOS .app bundle for World Clock.

Usage:
    python3 build_macos_app.py [--sign <identity>]

This script creates World Clock.app in the current directory.
On macOS, you can optionally code-sign it with --sign.
"""
import os
import sys
import shutil
import subprocess
from pathlib import Path


def run(cmd, check=True):
    """Run a shell command and return its output."""
    print(f"  → {' '.join(cmd)}")
    result = subprocess.run(cmd, check=check, capture_output=True, text=True)
    if result.returncode != 0 and check:
        print(f"Error: {result.stderr}")
        sys.exit(1)
    return result.stdout.strip()


def main():
    project_dir = Path(__file__).parent
    app_name = "World Clock"
    app_bundle = f"{app_name}.app"
    app_dir = project_dir / app_bundle

    print(f"Building {app_name} for macOS...")

    # Clean up any existing build
    if app_dir.exists():
        print(f"Removing existing {app_bundle}...")
        shutil.rmtree(app_dir)

    # Create app bundle structure
    print("Creating app bundle structure...")
    contents_dir = app_dir / "Contents"
    macos_dir = contents_dir / "MacOS"
    resources_dir = contents_dir / "Resources"

    macos_dir.mkdir(parents=True, exist_ok=True)
    resources_dir.mkdir(parents=True, exist_ok=True)

    # Copy the main script
    print("Copying application files...")
    shutil.copy(project_dir / "world_clock.py", macos_dir / "world_clock")
    shutil.copy(project_dir / "assets", resources_dir, dirs_exist_ok=True)

    # Create a launcher script
    launcher_path = macos_dir / "World Clock"
    launcher_script = f"""#!/bin/bash
# Launcher for World Clock
SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
cd "$(dirname "$SCRIPT_DIR")/Resources"
python3 "$SCRIPT_DIR/world_clock"
"""
    launcher_path.write_text(launcher_script)
    launcher_path.chmod(0o755)

    # Create Info.plist
    plist_path = contents_dir / "Info.plist"
    info_plist = f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>{app_name}</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.world-clock</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>{app_name}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHumanReadableCopyright</key>
    <string>MIT License</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
"""
    plist_path.write_text(info_plist)

    print(f"✓ {app_bundle} created successfully!")
    print(f"  Location: {app_dir}")
    print(f"\nTo run the app:")
    print(f"  open {app_bundle}")
    print(f"\nTo add to Dock:")
    print(f"  1. open {app_bundle}")
    print(f"  2. Right-click the app in Dock → Options → Keep in Dock")

    # Code signing (optional)
    if "--sign" in sys.argv:
        sign_idx = sys.argv.index("--sign")
        if sign_idx + 1 < len(sys.argv):
            identity = sys.argv[sign_idx + 1]
            print(f"\nCode-signing with identity: {identity}")
            run([
                "codesign",
                "--deep",
                "--force",
                "--verify",
                "--verbose",
                "--sign", identity,
                str(app_dir)
            ])
            print("✓ Code-signing complete!")


if __name__ == "__main__":
    main()
