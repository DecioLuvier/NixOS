cmake_minimum_required(VERSION 3.20)
project(bars LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK4 REQUIRED gtk4)
pkg_check_modules(LAYER_SHELL REQUIRED gtk-layer-shell-0)

add_executable(bars
    src/main.cpp
    src/bar_window.cpp
)

target_include_directories(bars PRIVATE ${GTK4_INCLUDE_DIRS} ${LAYER_SHELL_INCLUDE_DIRS})
target_link_libraries(bars PRIVATE ${GTK4_LIBRARIES} ${LAYER_SHELL_LIBRARIES})
target_compile_options(bars PRIVATE ${GTK4_CFLAGS_OTHER} ${LAYER_SHELL_CFLAGS_OTHER})
link_directories(${GTK4_LIBRARY_DIRS} ${LAYER_SHELL_LIBRARY_DIRS})

install(TARGETS bars RUNTIME DESTINATION bin)
