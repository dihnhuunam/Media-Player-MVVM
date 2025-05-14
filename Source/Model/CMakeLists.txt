add_library(lModel SHARED
    AuthModel.cpp
    SongModel.cpp
)

list(APPEND CMAKE_PREFIX_PATH "/home/dihnhuunam/Qt/6.8.2/gcc_64")
find_package(Qt6 
    REQUIRED 
    COMPONENTS 
        Core
        Quick 
        Multimedia 
        Qml
        Gui
        Network
)

target_include_directories(lModel PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(lModel PUBLIC
    Qt6::Core
    Qt6::Quick
    Qt6::Multimedia
    Qt6::Qml
    Qt6::Gui
    Qt6::Network
)