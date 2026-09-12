#pragma once
#include <functional>

namespace hyprland {

int active_workspace_window_count();
void on_window_count_changed(std::function<void()> callback);

} // namespace hyprland
