#include "bottombar.h"
#include <gtk4-layer-shell.h>

namespace bottombar {
namespace {
constexpr int kHeight = 44;
constexpr int kWidth = 500;
constexpr int kMargin = 10;
} // namespace

GtkWidget* create(GtkApplication* app) {
    GtkWidget* window = gtk_application_window_new(app);
    gtk_widget_add_css_class(window, "bar");
    gtk_widget_add_css_class(window, "bar-bottom");
    gtk_widget_set_size_request(window, kWidth, kHeight);

    GtkWidget* box = gtk_center_box_new();
    gtk_widget_set_hexpand(box, TRUE);
    gtk_window_set_child(GTK_WINDOW(window), box);

    GtkWindow* win = GTK_WINDOW(window);
    gtk_layer_init_for_window(win);
    gtk_layer_set_layer(win, GTK_LAYER_SHELL_LAYER_TOP);
    gtk_layer_set_namespace(win, "bar-bottom");
    gtk_layer_set_anchor(win, GTK_LAYER_SHELL_EDGE_BOTTOM, TRUE);
    gtk_layer_set_margin(win, GTK_LAYER_SHELL_EDGE_BOTTOM, kMargin);
    gtk_layer_set_exclusive_zone(win, -1);

    gtk_window_present(win);
    return window;
}

} // namespace bottombar
