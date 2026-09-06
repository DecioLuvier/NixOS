// GTK4 layer-shell navbar for Hyprland — C++.
// Solid full-width bar, anchored to the BOTTOM edge.
// Left:  workspaces (active highlighted) + CPU/RAM.
// Right: keyboard layout | wifi | volume | battery | clock (time + date).

#include <gtk/gtk.h>
#include <gtk4-layer-shell.h>

#include <array>
#include <cctype>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <fstream>
#include <map>
#include <set>
#include <sstream>
#include <string>
#include <thread>
#include <vector>

#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

// ── palette ──────────────────────────────────────────────────────────────
// Solid grey bar, no rounding, no floating pills — matches the reference.
static const char *GLOBAL_CSS = R"CSS(
window        { background: #3c3c3c; }
.bar-root     { background: #3c3c3c; min-height: 26px; }

.ws-box       { background: transparent; padding: 0 4px; }
.ws-btn       { background: transparent; border: 1px solid transparent;
                border-radius: 3px; padding: 1px 5px; margin: 2px;
                color: #dcdcdc; min-width: 20px; }
.ws-btn:hover   { background: rgba(255,255,255,0.10); }
.ws-btn.active  { background: #2d2d2d; border-color: #4aa5f0; color: #ffffff; }

.sysinfo-lbl, .kbd-lbl, .audio-lbl, .net-lbl {
  color: #dcdcdc; font-size: 12px;
}
.right-box  { padding: 0 8px; }

.clock-box   { padding: 0 4px; }
.clock-time  { color: #ffffff; font-size: 11px; font-weight: bold; }
.clock-date  { color: #cfcfcf; font-size: 9px; }
)CSS";

// ── helpers ──────────────────────────────────────────────────────────────

static std::string run_cmd(const char *cmd) {
    std::string out;
    FILE *p = popen(cmd, "r");
    if (!p) return out;
    char buf[4096];
    size_t n;
    while ((n = fread(buf, 1, sizeof buf, p)) > 0) out.append(buf, n);
    pclose(p);
    return out;
}

static std::string trim(const std::string &s) {
    size_t a = s.find_first_not_of(" \t\r\n");
    if (a == std::string::npos) return "";
    size_t b = s.find_last_not_of(" \t\r\n");
    return s.substr(a, b - a + 1);
}

static std::vector<std::string> split(const std::string &s, char d) {
    std::vector<std::string> v;
    std::stringstream ss(s);
    std::string item;
    while (std::getline(ss, item, d)) v.push_back(item);
    return v;
}

// ── workspaces ───────────────────────────────────────────────────────────
// Minimal hyprctl -j parsing: we only need workspace ids, the active id,
// and per-workspace window classes. Cheap string scans, no JSON library.

struct Workspaces {
    GtkWidget *box;                       // .ws-box
    std::map<int, GtkWidget *> buttons;   // ws id -> button
};

static const std::array<std::pair<const char *, const char *>, 17> CLASS_ICON = {{
    {"firefox", "firefox"},
    {"chromium", "chromium"},
    {"google-chrome", "google-chrome"},
    {"code", "visual-studio-code"},
    {"code-oss", "code-oss"},
    {"alacritty", "utilities-terminal"},
    {"kitty", "utilities-terminal"},
    {"thunar", "system-file-manager"},
    {"nautilus", "org.gnome.Nautilus"},
    {"spotify", "spotify"},
    {"discord", "discord"},
    {"telegram-desktop", "telegram"},
    {"steam", "steam"},
    {"gimp", "gimp"},
    {"inkscape", "inkscape"},
    {"obsidian", "obsidian"},
    {"vlc", "vlc"},
}};

static const char *icon_for_class(const std::string &cls) {
    std::string lc = cls;
    for (auto &c : lc) c = (char)tolower((unsigned char)c);
    for (auto &kv : CLASS_ICON)
        if (lc.find(kv.first) != std::string::npos) return kv.second;
    return "application-x-executable";
}

static std::vector<int> scan_ints_after(const std::string &s, const std::string &key) {
    std::vector<int> out;
    size_t pos = 0;
    while ((pos = s.find(key, pos)) != std::string::npos) {
        pos += key.size();
        while (pos < s.size() && (s[pos] == ' ' || s[pos] == '\t')) pos++;
        bool neg = false;
        if (pos < s.size() && s[pos] == '-') { neg = true; pos++; }
        int val = 0;
        bool any = false;
        while (pos < s.size() && isdigit((unsigned char)s[pos])) {
            val = val * 10 + (s[pos] - '0');
            pos++;
            any = true;
        }
        if (any) out.push_back(neg ? -val : val);
    }
    return out;
}

static void ws_switch(GtkButton *, gpointer data) {
    int wid = GPOINTER_TO_INT(data);
    char cmd[64];
    snprintf(cmd, sizeof cmd, "hyprctl dispatch workspace %d >/dev/null 2>&1", wid);
    if (system(cmd)) { /* ignore */ }
}

// Parse `hyprctl -j clients` into ws id -> list of classes.
static std::map<int, std::vector<std::string>> parse_clients(const std::string &json) {
    std::map<int, std::vector<std::string>> result;
    size_t pos = 0;
    while ((pos = json.find("\"address\"", pos)) != std::string::npos) {
        size_t next = json.find("\"address\"", pos + 1);
        std::string rec = json.substr(pos, next == std::string::npos ? std::string::npos
                                                                     : next - pos);
        pos += 1;

        int wid = -1;
        size_t wp = rec.find("\"workspace\"");
        if (wp != std::string::npos) {
            auto ids = scan_ints_after(rec.substr(wp), "\"id\":");
            if (!ids.empty()) wid = ids[0];
        }

        std::string cls;
        size_t cp = rec.find("\"class\"");
        size_t colon = rec.find(':', cp);
        if (cp != std::string::npos && colon != std::string::npos) {
            size_t q1 = rec.find('"', colon);
            size_t q2 = q1 == std::string::npos ? std::string::npos : rec.find('"', q1 + 1);
            if (q1 != std::string::npos && q2 != std::string::npos)
                cls = rec.substr(q1 + 1, q2 - q1 - 1);
        }
        if (wid > 0 && !cls.empty()) result[wid].push_back(cls);
    }
    return result;
}

static gboolean ws_refresh(gpointer data) {
    auto *w = static_cast<Workspaces *>(data);

    std::string ws_json  = run_cmd("hyprctl -j workspaces 2>/dev/null");
    std::string cl_json   = run_cmd("hyprctl -j clients 2>/dev/null");
    std::string act_json  = run_cmd("hyprctl -j activeworkspace 2>/dev/null");

    int active_ws = 1;
    {
        auto ids = scan_ints_after(act_json, "\"id\":");
        if (!ids.empty()) active_ws = ids[0];
    }

    std::set<int> ws_ids;
    for (int id : scan_ints_after(ws_json, "\"id\":"))
        if (id > 0) ws_ids.insert(id);
    if (ws_ids.empty()) ws_ids.insert(1);

    auto ws_clients = parse_clients(cl_json);

    for (auto it = w->buttons.begin(); it != w->buttons.end();) {
        if (!ws_ids.count(it->first)) {
            gtk_box_remove(GTK_BOX(w->box), it->second);
            it = w->buttons.erase(it);
        } else {
            ++it;
        }
    }

    for (int wid : ws_ids) {
        GtkWidget *btn;
        auto found = w->buttons.find(wid);
        if (found == w->buttons.end()) {
            btn = gtk_button_new();
            gtk_widget_add_css_class(btn, "ws-btn");
            g_signal_connect(btn, "clicked", G_CALLBACK(ws_switch), GINT_TO_POINTER(wid));
            gtk_box_append(GTK_BOX(w->box), btn);
            w->buttons[wid] = btn;
        } else {
            btn = found->second;
        }

        GtkWidget *hbox = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 3);
        char num[16];
        snprintf(num, sizeof num, "%d", wid);
        gtk_box_append(GTK_BOX(hbox), gtk_label_new(num));

        auto &classes = ws_clients[wid];
        int shown = 0;
        for (auto &cls : classes) {
            if (shown++ >= 4) break;
            GtkWidget *img = gtk_image_new_from_icon_name(icon_for_class(cls));
            gtk_image_set_pixel_size(GTK_IMAGE(img), 14);
            gtk_box_append(GTK_BOX(hbox), img);
        }
        gtk_button_set_child(GTK_BUTTON(btn), hbox);

        if (wid == active_ws) gtk_widget_add_css_class(btn, "active");
        else                  gtk_widget_remove_css_class(btn, "active");
    }
    return G_SOURCE_CONTINUE;
}

static gboolean ws_refresh_once(gpointer data) {
    ws_refresh(data);
    return G_SOURCE_REMOVE;
}

static void ws_listen_socket(Workspaces *w) {
    const char *sig = getenv("HYPRLAND_INSTANCE_SIGNATURE");
    if (!sig) return;

    std::string path;
    if (const char *xdg = getenv("XDG_RUNTIME_DIR"))
        path = std::string(xdg) + "/hypr/" + sig + "/.socket2.sock";
    std::string legacy = std::string("/tmp/hypr/") + sig + "/.socket2.sock";

    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd < 0) return;

    sockaddr_un addr{};
    addr.sun_family = AF_UNIX;
    bool connected = false;
    for (const std::string &p : {path, legacy}) {
        if (p.empty()) continue;
        strncpy(addr.sun_path, p.c_str(), sizeof addr.sun_path - 1);
        if (connect(fd, (sockaddr *)&addr, sizeof addr) == 0) { connected = true; break; }
    }
    if (!connected) { close(fd); return; }

    std::string buf;
    char chunk[4096];
    ssize_t n;
    while ((n = read(fd, chunk, sizeof chunk)) > 0) {
        buf.append(chunk, n);
        size_t nl;
        while ((nl = buf.find('\n')) != std::string::npos) {
            std::string line = buf.substr(0, nl);
            buf.erase(0, nl + 1);
            std::string ev = line.substr(0, line.find(">>"));
            if (ev == "workspace" || ev == "focusedmon" || ev == "openwindow" ||
                ev == "closewindow" || ev == "movewindow" || ev == "activewindow") {
                g_idle_add(ws_refresh_once, w);
            }
        }
    }
    close(fd);
}

static GtkWidget *workspaces_new() {
    auto *w = new Workspaces();
    w->box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 2);
    gtk_widget_add_css_class(w->box, "ws-box");

    ws_refresh(w);
    g_timeout_add(2000, ws_refresh, w);
    std::thread(ws_listen_socket, w).detach();

    return w->box;
}

// ── sysinfo (CPU + RAM) ──────────────────────────────────────────────────
struct Sysinfo {
    GtkWidget *cpu;
    GtkWidget *ram;
    unsigned long long last_total = 0, last_idle = 0;
};

static void read_cpu(unsigned long long &total, unsigned long long &idle) {
    std::ifstream f("/proc/stat");
    std::string cpu;
    unsigned long long user, nice, sys, idl, iowait, irq, softirq, steal;
    f >> cpu >> user >> nice >> sys >> idl >> iowait >> irq >> softirq >> steal;
    idle  = idl + iowait;
    total = user + nice + sys + idl + iowait + irq + softirq + steal;
}

static void read_mem(double &used_gb, double &total_gb) {
    std::ifstream f("/proc/meminfo");
    std::string key;
    unsigned long long val, kb_total = 0, kb_avail = 0;
    std::string unit;
    while (f >> key >> val >> unit) {
        if (key == "MemTotal:")          kb_total = val;
        else if (key == "MemAvailable:") { kb_avail = val; break; }
    }
    total_gb = kb_total / 1024.0 / 1024.0;
    used_gb  = (kb_total - kb_avail) / 1024.0 / 1024.0;
}

static gboolean sysinfo_update(gpointer data) {
    auto *s = static_cast<Sysinfo *>(data);

    unsigned long long total, idle;
    read_cpu(total, idle);
    double cpu_pct = 0.0;
    if (s->last_total && total > s->last_total) {
        double dt = double(total - s->last_total);
        double di = double(idle - s->last_idle);
        cpu_pct = (dt - di) / dt * 100.0;
    }
    s->last_total = total;
    s->last_idle  = idle;

    double used_gb, total_gb;
    read_mem(used_gb, total_gb);

    char b[64];
    snprintf(b, sizeof b, " %.0f%%", cpu_pct);
    gtk_label_set_text(GTK_LABEL(s->cpu), b);
    snprintf(b, sizeof b, " %.1f/%.0fG", used_gb, total_gb);
    gtk_label_set_text(GTK_LABEL(s->ram), b);
    return G_SOURCE_CONTINUE;
}

static GtkWidget *sysinfo_new() {
    auto *s = new Sysinfo();
    GtkWidget *box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 8);
    s->cpu = gtk_label_new("");
    s->ram = gtk_label_new("");
    gtk_widget_add_css_class(s->cpu, "sysinfo-lbl");
    gtk_widget_add_css_class(s->ram, "sysinfo-lbl");
    gtk_box_append(GTK_BOX(box), s->cpu);
    gtk_box_append(GTK_BOX(box), s->ram);

    sysinfo_update(s);
    g_timeout_add(2000, sysinfo_update, s);
    return box;
}

// ── keyboard layout ──────────────────────────────────────────────────────
// Shows a short uppercase tag (ENG / POR / ...) from hyprctl devices.
static gboolean kbd_update(gpointer data) {
    GtkWidget *lbl = static_cast<GtkWidget *>(data);
    std::string out = run_cmd("hyprctl -j devices 2>/dev/null");

    // Look for the first "active_keymap": "<name>" entry.
    std::string keymap;
    size_t kp = out.find("\"active_keymap\"");
    if (kp != std::string::npos) {
        size_t colon = out.find(':', kp);
        size_t q1 = colon == std::string::npos ? std::string::npos : out.find('"', colon);
        size_t q2 = q1 == std::string::npos ? std::string::npos : out.find('"', q1 + 1);
        if (q1 != std::string::npos && q2 != std::string::npos)
            keymap = out.substr(q1 + 1, q2 - q1 - 1);
    }

    // Map common keymap names to a 3-letter tag.
    std::string tag = "ENG";
    std::string lc = keymap;
    for (auto &c : lc) c = (char)tolower((unsigned char)c);
    if      (lc.find("portug") != std::string::npos || lc.find("brazil") != std::string::npos)
        tag = "POR";
    else if (lc.find("spanish") != std::string::npos) tag = "ESP";
    else if (lc.find("french")  != std::string::npos) tag = "FRA";
    else if (lc.find("german")  != std::string::npos) tag = "GER";
    else if (lc.find("english") != std::string::npos || lc.find("us")      != std::string::npos)
        tag = "ENG";
    else if (!keymap.empty()) {
        tag = keymap.substr(0, 3);
        for (auto &c : tag) c = (char)toupper((unsigned char)c);
    }

    gtk_label_set_text(GTK_LABEL(lbl), tag.c_str());
    return G_SOURCE_CONTINUE;
}

static GtkWidget *kbd_new() {
    GtkWidget *lbl = gtk_label_new("ENG");
    gtk_widget_add_css_class(lbl, "kbd-lbl");
    kbd_update(lbl);
    g_timeout_add(2000, kbd_update, lbl);
    return lbl;
}

// ── audio (wpctl) ────────────────────────────────────────────────────────
static gboolean audio_update(gpointer data) {
    GtkWidget *lbl = static_cast<GtkWidget *>(data);
    std::string out = run_cmd("wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null");
    auto parts = split(trim(out), ' ');
    int vol = 0;
    bool muted = out.find("MUTED") != std::string::npos;
    if (parts.size() >= 2) vol = (int)(atof(parts[1].c_str()) * 100);

    std::string text;
    if (muted) {
        text = "\xF3\xB0\x96\x81";  // 󰖁 muted
    } else {
        const char *icon = vol > 50 ? "\xF3\xB0\x95\xBE"   // 󰕾
                        : (vol > 0  ? "\xF3\xB0\x96\x80"    // 󰖀
                                    : "\xF3\xB0\x95\xBF");  // 󰕿
        char b[32];
        snprintf(b, sizeof b, "%s %d%%", icon, vol);
        text = b;
    }
    gtk_label_set_text(GTK_LABEL(lbl), text.c_str());
    return G_SOURCE_CONTINUE;
}

static void audio_clicked(GtkButton *btn, gpointer) {
    if (system("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle >/dev/null 2>&1")) {}
    audio_update(gtk_button_get_child(btn));
}

static GtkWidget *audio_new() {
    GtkWidget *btn = gtk_button_new();
    gtk_widget_add_css_class(btn, "flat");
    GtkWidget *lbl = gtk_label_new("");
    gtk_widget_add_css_class(lbl, "audio-lbl");
    gtk_button_set_child(GTK_BUTTON(btn), lbl);

    audio_update(lbl);
    g_timeout_add(2000, audio_update, lbl);
    g_signal_connect(btn, "clicked", G_CALLBACK(audio_clicked), nullptr);
    return btn;
}

// ── battery (/sys/class/power_supply) ────────────────────────────────────
static gboolean battery_update(gpointer data) {
    GtkWidget *lbl = static_cast<GtkWidget *>(data);

    // Find the first BAT* supply.
    std::string base;
    for (const char *name : {"BAT0", "BAT1", "BAT2"}) {
        std::string p = std::string("/sys/class/power_supply/") + name + "/capacity";
        std::ifstream test(p);
        if (test.good()) { base = std::string("/sys/class/power_supply/") + name; break; }
    }
    if (base.empty()) {
        gtk_widget_set_visible(lbl, FALSE);
        return G_SOURCE_CONTINUE;
    }

    int cap = 0;
    { std::ifstream f(base + "/capacity"); f >> cap; }
    std::string status;
    { std::ifstream f(base + "/status"); std::getline(f, status); }
    bool charging = status == "Charging" || status == "Full";

    // Nerd-font battery ramp.
    const char *icon;
    if (charging)      icon = "\xF3\xB0\x82\x84";           // 󰂄
    else if (cap >= 90) icon = "\xF3\xB0\x81\xB9";          // 󰁹
    else if (cap >= 70) icon = "\xF3\xB0\x81\xBD";          // 󰁽
    else if (cap >= 50) icon = "\xF3\xB0\x81\xBB";          // 󰁻
    else if (cap >= 30) icon = "\xF3\xB0\x81\xB8";          // 󰁸
    else if (cap >= 10) icon = "\xF3\xB0\x81\xB4";          // 󰁴
    else                icon = "\xF3\xB0\x82\x8E";          // 󰂎

    char b[48];
    snprintf(b, sizeof b, "%s %d%%", icon, cap);
    gtk_widget_set_visible(lbl, TRUE);
    gtk_label_set_text(GTK_LABEL(lbl), b);
    return G_SOURCE_CONTINUE;
}

static GtkWidget *battery_new() {
    GtkWidget *lbl = gtk_label_new("");
    gtk_widget_add_css_class(lbl, "net-lbl");
    battery_update(lbl);
    g_timeout_add(10000, battery_update, lbl);
    return lbl;
}

// ── network (nmcli) ──────────────────────────────────────────────────────
static gboolean network_update(gpointer data) {
    GtkWidget *lbl = static_cast<GtkWidget *>(data);
    std::string out = run_cmd(
        "nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null");

    bool connected = false;
    std::string name;
    for (auto &line : split(out, '\n')) {
        auto p = split(line, ':');
        if (p.size() >= 3 && p[1] == "connected") {
            connected = true;
            if (p[0] == "wifi")          { name = p[2]; break; }
            else if (p[0] == "ethernet") { name = "eth"; break; }
        }
    }

    // Icon only, to match the reference (no SSID text).
    std::string text;
    if (connected) text = "\xF3\xB0\xA4\xA8";  // 󰤨
    else           text = "\xF3\xB0\xA4\xAD";  // 󰤭
    gtk_label_set_text(GTK_LABEL(lbl), text.c_str());
    return G_SOURCE_CONTINUE;
}

static GtkWidget *network_new() {
    GtkWidget *lbl = gtk_label_new("");
    gtk_widget_add_css_class(lbl, "net-lbl");
    network_update(lbl);
    g_timeout_add(5000, network_update, lbl);
    return lbl;
}

// ── clock (time on top, date below) ──────────────────────────────────────
struct Clock { GtkWidget *time_lbl; GtkWidget *date_lbl; };

static gboolean clock_update(gpointer data) {
    auto *c = static_cast<Clock *>(data);
    time_t t = time(nullptr);
    struct tm tm_buf;
    localtime_r(&t, &tm_buf);
    char b[32];
    strftime(b, sizeof b, "%H:%M", &tm_buf);
    gtk_label_set_text(GTK_LABEL(c->time_lbl), b);
    strftime(b, sizeof b, "%d/%m/%Y", &tm_buf);
    gtk_label_set_text(GTK_LABEL(c->date_lbl), b);
    return G_SOURCE_CONTINUE;
}

static GtkWidget *clock_new() {
    auto *c = new Clock();
    GtkWidget *box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
    gtk_widget_add_css_class(box, "clock-box");
    gtk_widget_set_valign(box, GTK_ALIGN_CENTER);

    c->time_lbl = gtk_label_new("");
    c->date_lbl = gtk_label_new("");
    gtk_widget_add_css_class(c->time_lbl, "clock-time");
    gtk_widget_add_css_class(c->date_lbl, "clock-date");
    gtk_label_set_xalign(GTK_LABEL(c->time_lbl), 1.0);
    gtk_label_set_xalign(GTK_LABEL(c->date_lbl), 1.0);
    gtk_box_append(GTK_BOX(box), c->time_lbl);
    gtk_box_append(GTK_BOX(box), c->date_lbl);

    clock_update(c);
    g_timeout_add(10000, clock_update, c);
    return box;
}

// ── window assembly ──────────────────────────────────────────────────────
static void apply_global_css() {
    GtkCssProvider *provider = gtk_css_provider_new();
    gtk_css_provider_load_from_string(provider, GLOBAL_CSS);
    gtk_style_context_add_provider_for_display(
        gdk_display_get_default(), GTK_STYLE_PROVIDER(provider),
        GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
    g_object_unref(provider);
}

static void on_activate(GtkApplication *app, gpointer) {
    apply_global_css();

    GtkWidget *win = gtk_application_window_new(app);
    gtk_window_set_decorated(GTK_WINDOW(win), FALSE);

    gtk_layer_init_for_window(GTK_WINDOW(win));
    gtk_layer_set_layer(GTK_WINDOW(win), GTK_LAYER_SHELL_LAYER_TOP);
    gtk_layer_set_namespace(GTK_WINDOW(win), "navbar");
    gtk_layer_auto_exclusive_zone_enable(GTK_WINDOW(win));

    // Solid full-width bar glued to the BOTTOM edge.
    gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_BOTTOM, TRUE);
    gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_LEFT,   TRUE);
    gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_RIGHT,  TRUE);
    gtk_layer_set_margin(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_BOTTOM, 0);
    gtk_layer_set_margin(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_LEFT,   0);
    gtk_layer_set_margin(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_RIGHT,  0);

    GtkWidget *root = gtk_center_box_new();
    gtk_widget_add_css_class(root, "bar-root");
    gtk_window_set_child(GTK_WINDOW(win), root);

    // LEFT: workspaces + CPU/RAM
    GtkWidget *left = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10);
    gtk_widget_set_valign(left, GTK_ALIGN_CENTER);
    gtk_box_append(GTK_BOX(left), workspaces_new());
    gtk_box_append(GTK_BOX(left), sysinfo_new());
    gtk_center_box_set_start_widget(GTK_CENTER_BOX(root), left);

    // CENTRE: empty (reference has nothing here)
    gtk_center_box_set_center_widget(GTK_CENTER_BOX(root),
                                     gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0));

    // RIGHT: keyboard | wifi | volume | battery | clock
    GtkWidget *right = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 12);
    gtk_widget_add_css_class(right, "right-box");
    gtk_widget_set_valign(right, GTK_ALIGN_CENTER);

    GtkWidget *parts[] = {
        kbd_new(),
        network_new(),
        audio_new(),
        battery_new(),
        clock_new(),
    };
    for (GtkWidget *p : parts) gtk_box_append(GTK_BOX(right), p);
    gtk_center_box_set_end_widget(GTK_CENTER_BOX(root), right);

    gtk_window_present(GTK_WINDOW(win));
}

int main(int argc, char **argv) {
    GtkApplication *app =
        gtk_application_new("com.luvier.navbar", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(on_activate), nullptr);
    int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);
    return status;
}
