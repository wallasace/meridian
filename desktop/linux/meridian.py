#!/usr/bin/env python3
"""Meridian for Linux: a borderless GTK window hosting WebKitGTK.

Mirrors the macOS and Windows wrappers — the page draws its own title bar, and
this file only provides the window and answers the messages the page sends.

Dependencies (system packages, no pip):
    Debian/Ubuntu  sudo apt install python3-gi gir1.2-webkit2-4.1
    Fedora         sudo dnf install python3-gobject webkit2gtk4.1
    Arch           sudo pacman -S python-gobject webkit2gtk-4.1
"""
import json
import os
import sys

import gi

gi.require_version("Gtk", "3.0")
# 4.1 is current; 4.0 is kept as a fallback for older distributions.
try:
    gi.require_version("WebKit2", "4.1")
except ValueError:
    gi.require_version("WebKit2", "4.0")
from gi.repository import Gdk, Gio, GLib, Gtk, WebKit2  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
PAGE = os.path.join(HERE, "index.html")
if not os.path.exists(PAGE):  # running straight from a clone
    PAGE = os.path.normpath(os.path.join(HERE, "..", "..", "index.html"))

class Meridian(Gtk.Window):
    def __init__(self):
        super().__init__(title="Meridian")
        self.set_default_size(768, 500)
        self.set_size_request(360, 440)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_decorated(False)
        self.set_app_paintable(True)

        icon = os.path.join(HERE, "meridian.png")
        if os.path.exists(icon):
            self.set_icon_from_file(icon)

        # Transparency, so the card's rounded corners and shadow show through.
        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual is not None and screen.is_composited():
            self.set_visual(visual)

        manager = WebKit2.UserContentManager()
        manager.register_script_message_handler("bridge")
        manager.connect("script-message-received::bridge", self.on_message)
        manager.add_script(
            WebKit2.UserScript(
                self._bridge_js(),
                WebKit2.UserContentInjectedFrames.TOP_FRAME,
                WebKit2.UserScriptInjectionTime.START,
                None,
                None,
            )
        )

        self.web = WebKit2.WebView.new_with_user_content_manager(manager)
        self.web.set_background_color(Gdk.RGBA(0, 0, 0, 0))
        self.web.connect("decide-policy", self.on_policy)

        settings = self.web.get_settings()
        settings.set_enable_developer_extras(False)
        settings.set_enable_write_console_messages_to_stdout(False)

        self.add(self.web)
        self.web.load_uri(GLib.filename_to_uri(PAGE, None))

        self.connect("destroy", Gtk.main_quit)
        self.connect("key-press-event", self.on_key)

    @staticmethod
    def _bridge_js():
        # Same surface the page already uses on macOS and Windows.
        return """
        window.MERIDIAN_NATIVE = true;
        document.documentElement.classList.add('native');
        (function () {
          var native = window.webkit && window.webkit.messageHandlers;
          window.webkit = window.webkit || {};
          window.webkit.messageHandlers = new Proxy({}, {
            get: function (_, name) {
              return {
                postMessage: function (value) {
                  // Resolved at call time: the native channel may land after this script.
                  var ch = (native || (window.webkit && window.webkit.messageHandlers) || {}).bridge;
                  if (ch) ch.postMessage(JSON.stringify({
                    name: String(name), value: value
                  }));
                }
              };
            }
          });
        })();
        """

    def on_message(self, _manager, result):
        try:
            payload = json.loads(result.get_js_value().to_string())
        except (ValueError, AttributeError):
            return
        name, value = payload.get("name"), payload.get("value")

        if name == "close":
            self.close()
        elif name == "minimize":
            self.iconify()
        elif name == "drag":
            # Hand the drag to the window manager, which owns window movement.
            pointer = Gdk.Display.get_default().get_default_seat().get_pointer()
            _screen, x, y = pointer.get_position()
            self.begin_move_drag(1, x, y, Gtk.get_current_event_time())
        elif name == "pin":
            self.set_keep_above(bool(value))

    def on_policy(self, _web, decision, kind):
        # External links open in the default browser, never inside this window.
        if kind == WebKit2.PolicyDecisionType.NAVIGATION_ACTION:
            nav = decision.get_navigation_action()
            uri = nav.get_request().get_uri()
            if nav.get_navigation_type() == WebKit2.NavigationType.LINK_CLICKED \
                    and uri.startswith("http"):
                Gio.AppInfo.launch_default_for_uri(uri, None)
                decision.ignore()
                return True
        elif kind == WebKit2.PolicyDecisionType.NEW_WINDOW_ACTION:
            decision.ignore()
            return True
        return False

    def on_key(self, _widget, event):
        ctrl = event.state & Gdk.ModifierType.CONTROL_MASK
        key = Gdk.keyval_name(event.keyval)
        if ctrl and key in ("w", "q"):
            self.close()
            return True
        if ctrl and key == "m":
            self.iconify()
            return True
        return False


def main():
    if not os.path.exists(PAGE):
        print(f"index.html not found next to {HERE}", file=sys.stderr)
        return 1
    win = Meridian()
    win.show_all()
    Gtk.main()
    return 0


if __name__ == "__main__":
    sys.exit(main())
