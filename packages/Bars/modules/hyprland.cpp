#include "hyprland.h"

#include <glib.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#include <cstdlib>
#include <cstring>
#include <string>
#include <thread>

namespace hyprland {
namespace {

std::string socket_path(const char* name) {
    return std::string(g_getenv("XDG_RUNTIME_DIR")) + "/hypr/" +
           g_getenv("HYPRLAND_INSTANCE_SIGNATURE") + "/" + name;
}

int connect_socket(const std::string& path) {
    int fd = socket(AF_UNIX, SOCK_STREAM, 0);

    sockaddr_un addr{};
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, path.c_str(), sizeof(addr.sun_path) - 1);

    if (connect(fd, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) != 0) {
        close(fd);
        return -1;
    }
    return fd;
}

std::string send_command(const std::string& cmd) {
    int fd = connect_socket(socket_path(".socket.sock"));
    if (fd < 0) return "";

    ssize_t written = write(fd, cmd.data(), cmd.size());
    (void)written;

    std::string reply;
    char buf[4096];
    ssize_t n;
    while ((n = read(fd, buf, sizeof(buf))) > 0) {
        reply.append(buf, n);
    }
    close(fd);
    return reply;
}

gboolean invoke_callback(gpointer data) {
    auto* callback = static_cast<std::function<void()>*>(data);
    (*callback)();
    delete callback;
    return G_SOURCE_REMOVE;
}

} // namespace

int active_workspace_window_count() {
    std::string reply = send_command("activeworkspace");
    size_t pos = reply.find("windows:");
    return pos == std::string::npos ? 0 : std::atoi(reply.c_str() + pos + 8);
}

void on_window_count_changed(std::function<void()> callback) {
    std::thread([callback] {
        int fd = connect_socket(socket_path(".socket2.sock"));
        if (fd < 0) return;

        std::string buffer;
        char chunk[4096];
        ssize_t n;
        while ((n = read(fd, chunk, sizeof(chunk))) > 0) {
            buffer.append(chunk, n);

            size_t newline;
            while ((newline = buffer.find('\n')) != std::string::npos) {
                std::string line = buffer.substr(0, newline);
                buffer.erase(0, newline + 1);

                bool relevant = line.rfind("workspace>>", 0) == 0 ||
                                line.rfind("openwindow>>", 0) == 0 ||
                                line.rfind("closewindow>>", 0) == 0 ||
                                line.rfind("movewindow>>", 0) == 0;
                if (relevant) {
                    g_idle_add(invoke_callback, new std::function<void()>(callback));
                }
            }
        }
        close(fd);
    }).detach();
}

} // namespace hyprland
