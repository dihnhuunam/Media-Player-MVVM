# Collect all .cpp files in the current directory
file(GLOB CONFIG_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")

# Create shared library for lConfig
add_library(lConfig SHARED ${CONFIG_SOURCES})

# Use system Qt6; remove custom path if system Qt6 is preferred
list(APPEND CMAKE_PREFIX_PATH "/home/dihnhuunam/Qt/6.9.1/gcc_64")
# list(APPEND CMAKE_PREFIX_PATH "/usr/lib/x86_64-linux-gnu/cmake/Qt6SerialPort/")

find_package(Qt6 
    REQUIRED 
    COMPONENTS 
        Core
        Quick 
        Multimedia 
        Qml
        Gui
        Network
        SerialPort
)

# Include directories
target_include_directories(lConfig PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Link dependencies
target_link_libraries(lConfig PUBLIC
    Qt6::Core
    Qt6::Quick
    Qt6::Multimedia
    Qt6::Qml
    Qt6::Gui
    Qt6::Network
    Qt6::SerialPort
)