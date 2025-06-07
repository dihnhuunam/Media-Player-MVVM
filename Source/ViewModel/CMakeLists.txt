# Collect all .cpp files recursively from subdirectories
file(GLOB VIEWMODEL_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/Admin/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/Authentication/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/Client/*.cpp"
)

# Create shared library for ViewModel
add_library(lViewModel SHARED ${VIEWMODEL_SOURCES})

# Include directories
target_include_directories(lViewModel PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/Admin
    ${CMAKE_CURRENT_SOURCE_DIR}/Authentication
    ${CMAKE_CURRENT_SOURCE_DIR}/Client
)

# Link dependencies
target_link_libraries(lViewModel PUBLIC
    lModel
)