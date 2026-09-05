import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, GLib
import json, subprocess, socket, os, threading

BG     = "#111827"
ACCENT = "#025939"
FG     = "#ffffff"

CLASS_ICON = {
    "firefox":           "firefox",
    "chromium":          "chromium",
    "google-chrome":     "google-chrome",
    "code":              "visual-studio-code",
    "code-oss":          "code-oss",
    "alacritty":         "utilities-terminal",
    "kitty":             "utilities-terminal",
    "thunar":            "system-file-manager",
    "nautilus":          "org.gnome.Nautilus",
    "spotify":           "spotify",
    "discord":           "discord",
    "telegram-desktop":  "telegram",
    "steam":             "steam",
    "gimp":              "gimp",
    "inkscape":          "inkscape",
    "obsidian":          "obsidian",
    "github-desktop":    "github-desktop",
    "vlc":               "vlc",
}

def icon_for_class(cls: str) -> str:
    cls_lower = cls.lower()
    for key, icon in CLASS_ICON.items():
        if key in cls_lower:
            return icon
    return "application-x-executable"

def run_hyprctl(args: list[str]) -> list:
    try:
        r = subprocess.run(["hyprctl", "-j"] + args, capture_output=True, text=True, timeout=2)
        return json.loads(r.stdout)
    except Exception:
        return []

CSS = f"""
.ws-box {{
  background: {BG};
  border-radius: 12px;
  padding: 4px 8px;
}}
.ws-btn {{
  background: transparent;
  border-radius: 8px;
  padding: 2px 6px;
  color: {FG};
  border: none;
  min-width: 28px;
}}
.ws-btn:hover {{
  background: rgba(255,255,255,0.08);
}}
.ws-btn.active {{
  background: {ACCENT};
}}
"""

class WorkspacesWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        self.add_css_class("ws-box")
        self._buttons: dict[int, Gtk.Button] = {}
        self._refresh()
        GLib.timeout_add(2000, self._refresh)
        threading.Thread(target=self._listen_socket, daemon=True).start()

    def _listen_socket(self):
        sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
        path = f"/tmp/hypr/{sig}/.socket2.sock"
        try:
            with socket.socket(socket.AF_UNIX) as s:
                s.connect(path)
                s.settimeout(None)
                buf = ""
                while True:
                    data = s.recv(4096).decode("utf-8", errors="replace")
                    buf += data
                    while "\n" in buf:
                        line, buf = buf.split("\n", 1)
                        ev = line.split(">>")[0]
                        if ev in ("workspace", "focusedmon", "openwindow", "closewindow", "movewindow", "activewindow"):
                            GLib.idle_add(self._refresh)
        except Exception:
            pass

    def _refresh(self):
        workspaces = run_hyprctl(["workspaces"])
        clients    = run_hyprctl(["clients"])
        active_ws  = 1
        try:
            active_raw = run_hyprctl(["activeworkspace"])
            active_ws  = active_raw.get("id", 1)
        except Exception:
            pass

        ws_clients: dict[int, list[str]] = {}
        for c in clients:
            wid = c.get("workspace", {}).get("id", -1)
            cls = c.get("class", "") or ""
            if wid > 0:
                ws_clients.setdefault(wid, []).append(cls)

        ws_ids = sorted({w["id"] for w in workspaces if w["id"] > 0})
        for wid in ws_ids:
            if wid not in ws_clients:
                ws_clients[wid] = []

        existing = set(self._buttons.keys())
        wanted   = set(ws_ids)

        for wid in existing - wanted:
            btn = self._buttons.pop(wid)
            self.remove(btn)

        for wid in sorted(ws_ids):
            icons = ws_clients.get(wid, [])
            if wid not in self._buttons:
                btn = Gtk.Button()
                btn.add_css_class("ws-btn")
                btn.connect("clicked", lambda _b, w=wid: self._switch(w))
                self._buttons[wid] = btn
                self.append(btn)
            btn = self._buttons[wid]
            box = Gtk.Box(spacing=2)
            lbl = Gtk.Label(label=str(wid))
            box.append(lbl)
            for cls in icons[:4]:
                img = Gtk.Image.new_from_icon_name(icon_for_class(cls))
                img.set_pixel_size(14)
                box.append(img)
            btn.set_child(box)
            if wid == active_ws:
                if not btn.has_css_class("active"):
                    btn.add_css_class("active")
            else:
                btn.remove_css_class("active")
        return True

    def _switch(self, wid: int):
        subprocess.Popen(["hyprctl", "dispatch", "workspace", str(wid)])

def load_css():
    provider = Gtk.CssProvider()
    provider.load_from_string(CSS)
    Gtk.StyleContext.add_provider_for_display(
        Gtk.Widget.get_default_display() if hasattr(Gtk.Widget, "get_default_display") else __import__("gi.repository.Gdk", fromlist=["Gdk"]).Display.get_default(),
        provider,
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
    )
