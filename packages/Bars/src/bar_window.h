#pragma once
#include <gtk/gtk.h>

enum class BarEdge { Top, Bottom };

class BarWindow {
public:
    BarWindow(GtkApplication* app, BarEdge edge, int height);
    GtkWidget* widget() const { return window_; }

private:
    GtkWidget* window_;
    void setup_layer_shell(BarEdge edge, int height);
};
