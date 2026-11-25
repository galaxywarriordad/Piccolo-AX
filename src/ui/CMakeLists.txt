add_library(ax_ui_retro INTERFACE)

target_include_directories(ax_ui_retro
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/..
)

target_compile_features(ax_ui_retro
    INTERFACE
        cxx_std_20
)
