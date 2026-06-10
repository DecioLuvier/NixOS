#include <gtkmm.h>

class MyWindow : public Gtk::Window {
public:
  MyWindow() {
    set_title("NixOS GTKmm4 Example");
    set_default_size(400, 200);
  }
};

int main(int argc, char* argv[]) {
  auto app = Gtk::Application::create("org.example.gtkmm4");
  return app->make_window_and_run<MyWindow>(argc, argv);
}
