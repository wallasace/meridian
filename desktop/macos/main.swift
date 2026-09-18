import Cocoa
import WebKit

/// A .borderless window refuses to become key/main by default, and while it
/// isn't key AppKit withholds mouseMoved — so no CSS :hover fires until the
/// first click, and then sticks. Accepting focus fixes both.
final class PanelWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    var window: NSWindow!
    var web: WKWebView!

    func applicationDidFinishLaunching(_ note: Notification) {
        let cfg = WKWebViewConfiguration()
        cfg.websiteDataStore = .default()

        // The page identifies itself as "inside the app" and reveals its own controls.
        cfg.userContentController.addUserScript(WKUserScript(
            source: "window.MERIDIAN_NATIVE=true;document.documentElement.classList.add('native');",
            injectionTime: .atDocumentStart, forMainFrameOnly: true))
        for name in ["close", "minimize", "drag", "pin"] {
            cfg.userContentController.add(self, name: name)
        }

        web = WKWebView(frame: .zero, configuration: cfg)
        web.navigationDelegate = self
        web.setValue(false, forKey: "drawsBackground")

        let size = NSSize(width: 768, height: 500)
        window = PanelWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.acceptsMouseMovedEvents = true
        window.title = "Meridian"
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false          // the card's CSS draws the shadow
        window.isMovableByWindowBackground = true
        window.minSize = NSSize(width: 360, height: 440)
        window.contentView = web
        window.setFrameAutosaveName("MeridianWindow")
        window.center()
        window.makeKeyAndOrderFront(nil)

        // With no title bar, the keyboard needs an explicit path to close.
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] ev in
            let cmd = ev.modifierFlags.contains(.command)
            if cmd && ev.charactersIgnoringModifiers == "w" { self?.window.close(); return nil }
            if cmd && ev.charactersIgnoringModifiers == "m" { self?.window.miniaturize(nil); return nil }
            return ev
        }

        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        buildMenu()
    }

    // External links open in the browser, not inside the window.
    func webView(_ w: WKWebView, decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if action.navigationType == .linkActivated, let url = action.request.url {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func userContentController(_ c: WKUserContentController, didReceive msg: WKScriptMessage) {
        switch msg.name {
        case "close": window.close()
        case "minimize": window.miniaturize(nil)
        // The WebView swallows mouseDown, so the page asks for the drag explicitly.
        case "drag": if let ev = NSApp.currentEvent { window.performDrag(with: ev) }
        case "pin":
            let on = (msg.body as? Bool) ?? false
            window.level = on ? .floating : .normal
            // .floating alone disappears when switching Spaces; this keeps it visible.
            window.collectionBehavior = on ? [.canJoinAllSpaces, .fullScreenAuxiliary] : [.fullScreenAuxiliary]
        default: break
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { true }

    private func buildMenu() {
        let main = NSMenu()
        let appItem = NSMenuItem()
        main.addItem(appItem)
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About Meridian", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Hide Meridian", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(withTitle: "Quit Meridian", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu
        NSApp.mainMenu = main
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
