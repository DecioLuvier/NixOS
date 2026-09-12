#include <gtk/gtk.h>
#include "modules/topbar.h"
#include "modules/bottombar.h"
#include "modules/hyprland.h"

static void load_css() {
    const char* css_path = g_getenv("BARS_CSS_PATH");
    if (!css_path) {
        css_path = "main.css";
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

static void update_bottom_visibility(GtkWidget* bottom_widget) {
    gtk_widget_set_visible(bottom_widget, hyprland::active_workspace_window_count() == 0);
}

static void on_activate(GtkApplication* app, gpointer) {
    load_css();
    topbar::create(app);
    GtkWidget* bottom_widget = bottombar::create(app);

    update_bottom_visibility(bottom_widget);
    hyprland::on_window_count_changed([bottom_widget] {
        update_bottom_visibility(bottom_widget);
    });
}

int main(int argc, char** argv) {
    GtkApplication* app = gtk_application_new("org.decio.bars", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(on_activate), nullptr);
    int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);
    return status;
}
