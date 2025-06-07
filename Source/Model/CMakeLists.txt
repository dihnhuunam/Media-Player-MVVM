# Collect all .cpp files recursively from subdirectories
file(GLOB MODEL_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/Admin/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/Authentication/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/Client/*.cpp"
)

# Create shared library for Model
add_library(lModel SHARED ${MODEL_SOURCES})

# Include directories
target_include_directories(lModel PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/Admin
    ${CMAKE_CURRENT_SOURCE_DIR}/Authentication
    ${CMAKE_CURRENT_SOURCE_DIR}/Client
)

# Link dependencies
target_link_libraries(lModel PUBLIC
    lConfig
)