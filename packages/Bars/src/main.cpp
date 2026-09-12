#include <gtk/gtk.h>
#include "bar_window.h"

static void load_css() {
    const char* css_path = g_getenv("BARS_CSS_PATH");
    if (!css_path) {
        css_path = "style.css";
    }

    GtkCssProvider* provider = gtk_css_provider_new();
    GFile* file = g_file_new_for_path(css_path);
    gtk_css_provider_load_from_file(provider, file);
    g_object_unref(file);

    gtk_style_context_add_provider_for_display(
        gdk_display_get_default(),
        GTK_STYLE_PROVIDER(provider),
        GTK_STYLE_PROVIDER_PRIORITY_USER
    );
    g_object_unref(provider);
}

static void on_activate(GtkApplication* app, gpointer) {
    load_css();
    static BarWindow* top    = new BarWindow(app, BarEdge::Top, 32);
    static BarWindow* bottom = new BarWindow(app, BarEdge::Bottom, 32);
}

int main(int argc, char** argv) {
    GtkApplication* app = gtk_application_new("org.decio.bars", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(on_activate), nullptr);
    int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);
    return status;
}
