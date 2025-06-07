add_library(lModel SHARED
    AuthModel.cpp
    SongModel.cpp
    PlaylistModel.cpp
    AdminModel.cpp
    UartModel.cpp
)

target_include_directories(lModel PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(lModel PUBLIC
    lConfig
)