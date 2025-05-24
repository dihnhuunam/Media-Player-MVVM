add_library(lConfig SHARED 
    AppConfig.cpp
    AppState.cpp
)

target_include_directories(lConfig PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
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

target_include_directories(lConfig PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(lConfig PUBLIC
    Qt6::Core
    Qt6::Quick
    Qt6::Multimedia
    Qt6::Qml
    Qt6::Gui
    Qt6::Network
)