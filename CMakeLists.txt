cmake_minimum_required(VERSION 3.16)

project(MediaPlayer)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

add_subdirectory(Source)
add_executable(${PROJECT_NAME}
    main.cpp
    resources.qrc
)

target_link_libraries(${PROJECT_NAME} PRIVATE 
    lViewModel
)

# list(APPEND CMAKE_PREFIX_PATH "/home/dihnhuunam/Qt/6.8.2/gcc_64")
# find_package(Qt6 
#     REQUIRED 
#     COMPONENTS 
#         Core
#         Quick 
#         Multimedia 
#         Qml
#         Gui
#         Network
# )
# target_link_libraries(${PROJECT_NAME} PUBLIC
#     Qt6::Core
#     Qt6::Quick
#     Qt6::Multimedia
#     Qt6::Qml
#     Qt6::Gui
#     Qt6::Network
# )