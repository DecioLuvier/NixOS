#include "bar_window.h"
#include <gtk4-layer-shell.h>

BarWindow::BarWindow(GtkApplication* app, BarEdge edge, int height) {
    window_ = gtk_application_window_new(app);
    gtk_widget_add_css_class(window_, "bar");
    gtk_widget_add_css_class(window_, edge == BarEdge::Top ? "bar-top" : "bar-bottom");
    gtk_widget_set_size_request(window_, -1, height);

    setup_layer_shell(edge, height);

    GtkWidget* box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_set_hexpand(box, TRUE);
    gtk_window_set_child(GTK_WINDOW(window_), box);

    gtk_window_present(GTK_WINDOW(window_));
}

void BarWindow::setup_layer_shell(BarEdge edge, int height) {
    GtkWindow* win = GTK_WINDOW(window_);

    gtk_layer_init_for_window(win);
    gtk_layer_set_layer(win, GTK_LAYER_SHELL_LAYER_TOP);
    gtk_layer_set_namespace(win, edge == BarEdge::Top ? "bar-top" : "bar-bottom");

    gtk_layer_set_anchor(win, GTK_LAYER_SHELL_EDGE_LEFT, TRUE);
    gtk_layer_set_anchor(win, GTK_LAYER_SHELL_EDGE_RIGHT, TRUE);
    gtk_layer_set_anchor(win, edge == BarEdge::Top
        ? GTK_LAYER_SHELL_EDGE_TOP
        : GTK_LAYER_SHELL_EDGE_BOTTOM, TRUE);

    gtk_layer_set_exclusive_zone(win, height);
}
