add_library(lViewModel SHARED
    AuthViewModel.cpp
    SongViewModel.cpp
    PlaylistViewModel.cpp
)

target_include_directories(lViewModel PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(lViewModel PUBLIC
    lModel
)