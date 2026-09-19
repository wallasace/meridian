// Meridian for Windows: a borderless window hosting WebView2, mirroring the
// macOS wrapper. The page draws its own title bar; this file only provides the
// window and answers the four messages the page sends (close/minimize/drag/pin).
using System;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Text.Json;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;

static class Program
{
    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        Application.Run(new MeridianForm());
    }
}

sealed class MeridianForm : Form
{
    readonly WebView2 web = new WebView2();

    // Lets the page drag the window: the same trick the macOS build uses, since
    // the WebView swallows the mouse-down before the frame ever sees it.
    const int WM_NCLBUTTONDOWN = 0xA1, HTCAPTION = 0x2;
    [DllImport("user32.dll")] static extern bool ReleaseCapture();
    [DllImport("user32.dll")] static extern IntPtr SendMessage(IntPtr h, int msg, int wp, int lp);

    public MeridianForm()
    {
        Text = "Meridian";
        FormBorderStyle = FormBorderStyle.None;
        StartPosition = FormStartPosition.CenterScreen;
        ClientSize = new Size(768, 500);
        MinimumSize = new Size(360, 440);
        BackColor = Color.FromArgb(16, 23, 34);
        KeyPreview = true;

        var ico = Path.Combine(AppContext.BaseDirectory, "meridian.ico");
        if (File.Exists(ico)) Icon = new Icon(ico);

        web.Dock = DockStyle.Fill;
        web.DefaultBackgroundColor = Color.Transparent;
        Controls.Add(web);
        _ = InitAsync();

        // No title bar means no system shortcuts; wire the usual two by hand.
        KeyDown += (s, e) =>
        {
            if (e.Control && e.KeyCode == Keys.W) Close();
            if (e.Control && e.KeyCode == Keys.M) WindowState = FormWindowState.Minimized;
        };
    }

    async Task InitAsync()
    {
        // Keep the profile beside the executable so the app stays portable:
        // unzip anywhere, and your saved destinations travel with it.
        var dataDir = Path.Combine(AppContext.BaseDirectory, "userdata");
        var env = await CoreWebView2Environment.CreateAsync(null, dataDir);
        await web.EnsureCoreWebView2Async(env);

        var core = web.CoreWebView2;
        core.Settings.AreDefaultContextMenusEnabled = false;
        core.Settings.IsStatusBarEnabled = false;
        core.Settings.AreDevToolsEnabled = false;

        await core.AddScriptToExecuteOnDocumentCreatedAsync(
            "window.MERIDIAN_NATIVE=true;" +
            // This runs before the document exists, so tagging <html> has to
            // wait for it — otherwise the window controls never appear.
            "(function(){var f=function(){document.documentElement.classList.add('native','win')};" +
            "if(document.documentElement){f()}" +
            "document.addEventListener('DOMContentLoaded',f);})();" +
            // WebView2 exposes one generic channel; adapt it to the same
            // webkit.messageHandlers shape the page already speaks.
            "window.webkit={messageHandlers:new Proxy({},{get:(_,name)=>({" +
            "postMessage:v=>window.chrome.webview.postMessage({name:String(name),value:v})})})};");

        core.WebMessageReceived += (s, e) =>
        {
            // Read everything out before queueing the work. A JsonElement is a
            // window onto the document's buffer, and BeginInvoke runs after this
            // handler returns — by then the document is disposed and reading
            // through the element throws.
            string name;
            bool flag;
            using (var doc = JsonDocument.Parse(e.WebMessageAsJson))
            {
                var root = doc.RootElement;
                if (!root.TryGetProperty("name", out var n)) return;
                name = n.GetString();
                flag = root.TryGetProperty("value", out var v)
                       && v.ValueKind == JsonValueKind.True;
            }

            BeginInvoke(new Action(() =>
            {
                switch (name)
                {
                    case "close": Close(); break;
                    case "minimize": WindowState = FormWindowState.Minimized; break;
                    case "drag":
                        ReleaseCapture();
                        SendMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
                        break;
                    case "pin":
                        TopMost = flag;
                        break;
                }
            }));
        };

        // External links go to the default browser, never inside this window.
        core.NewWindowRequested += (s, e) =>
        {
            e.Handled = true;
            OpenExternal(e.Uri);
        };
        core.NavigationStarting += (s, e) =>
        {
            if (e.Uri.StartsWith("http", StringComparison.OrdinalIgnoreCase))
            {
                e.Cancel = true;
                OpenExternal(e.Uri);
            }
        };

        var page = Path.Combine(AppContext.BaseDirectory, "index.html");
        if (File.Exists(page)) core.Navigate(new Uri(page).AbsoluteUri);
    }

    static void OpenExternal(string uri)
    {
        if (!uri.StartsWith("http", StringComparison.OrdinalIgnoreCase)) return;
        System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo(uri)
        {
            UseShellExecute = true
        });
    }

    // Rounded corners to match the card, so the square frame never peeks out.
    protected override void OnResize(EventArgs e)
    {
        base.OnResize(e);
        Region = new Region(Rounded(new Rectangle(0, 0, Width, Height), 12));
    }

    static System.Drawing.Drawing2D.GraphicsPath Rounded(Rectangle r, int radius)
    {
        var p = new System.Drawing.Drawing2D.GraphicsPath();
        int d = radius * 2;
        p.AddArc(r.X, r.Y, d, d, 180, 90);
        p.AddArc(r.Right - d, r.Y, d, d, 270, 90);
        p.AddArc(r.Right - d, r.Bottom - d, d, d, 0, 90);
        p.AddArc(r.X, r.Bottom - d, d, d, 90, 90);
        p.CloseFigure();
        return p;
    }
}
