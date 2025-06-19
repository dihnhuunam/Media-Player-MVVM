# Media Player MVVM

A modern, feature-rich media player application built with **Qt Quick/QML** and **C++** using the **MVVM (Model-View-ViewModel)** architecture. This application supports media playback, playlist management, user authentication, and admin functionalities, with a responsive and intuitive user interface.

## Table of Contents

- [Features](#features)
- [System Requirements](#system-requirements)
- [Project Structure](#project-structure)
- [Building and Running](#building-and-running)
- [Usage](#usage)

## Features

### User Features

- **Media Playback**:
  - Play, pause, stop, next/previous track controls.
  - Volume control with mute option.
  - Seek functionality for precise navigation.
  - Repeat modes (single track or entire playlist) and shuffle mode.
- **Playlist Management**:
  - Create, edit, and delete playlists.
  - Add, remove, and reorder tracks.
  - View detailed playlist information.
- **Profile Management**:
  - View and edit user profiles.
  - Customize player settings (e.g., theme, playback preferences).
  - Access playback history.

### Admin Features

- **User Management**:
  - View all registered users.
  - Assign or modify user roles (admin/user).
  - Enable or disable user accounts.
- **Media Management**:
  - Upload new media files.
  - Edit media metadata (e.g., title, artist, album).
  - Remove media files.
  - Manage file access permissions.

### Technical Features

- Modern, responsive UI built with **Qt Quick/QML**.
- **MVVM architecture** for clear separation of concerns.
- Efficient media handling using **Qt Multimedia**.
- Persistent storage for user data and playlists.
- Event-driven architecture for smooth interactions.
- Role-based access control for secure user/admin operations.

## System Requirements

### Build Requirements

- **Qt**: Version 6.8.2 or higher.
- **CMake**: Version 3.16 or higher.
- **Compiler**: C++17 compatible (e.g., GCC, Clang).
- **Qt Modules**: Qt Quick, Qt Multimedia.

### Runtime Requirements

- **Operating System**: Linux (primary support; other platforms may require additional configuration).
- **RAM**: Minimum 4GB.
- **Storage**: 100MB free space.
- **Graphics**: OpenGL 2.0 compatible graphics card.
- **Audio**: Working sound card or audio device.

## Project Structure

The project follows the **MVVM** architecture with a modular and organized structure:

```
Media-Player-MVVM/
├── Assets/                               # Application resources (e.g., images, icons)
├── Source/                               # Source code
│   ├── Model/                            # Data models and business logic
│   │   ├── PlaylistModel.cpp/hpp         # Playlist management logic
│   │   ├── SongModel.cpp/hpp             # Media file handling logic
│   │   └── CMakeLists.txt                # Model build configuration
│   ├── View/                             # QML-based UI
│   │   ├── Admin/                        # Admin views
│   │   │   ├── AdminDashboard.qml        # Admin dashboard
│   │   │   ├── AdminMediaFilesView.qml   # Media file management
│   │   │   └── AdminUploadFile.qml       # File upload interface
│   │   ├── Authentication/               # Authentication views
│   │   │   ├── LoginView.qml             # Login interface
│   │   │   └── RegisterView.qml          # Registration interface
│   │   ├── Client/                       # User interface
│   │   │   ├── MediaFileView.qml         # Media browsing
│   │   │   ├── MediaPlayerView.qml       # Media playback
│   │   │   ├── PlaylistView.qml          # Playlist viewing
│   │   │   └── ProfileView.qml           # User profile
│   │   ├── Components/                   # Reusable QML components
│   │   │   ├── HoverButton.qml           # Custom button with hover effect
│   │   │   └── SliderComponent.qml       # Slider for seeking/volume
│   │   ├── Helper/                       # UI utilities
│   │   │   ├── Main.qml                  # Main QML entry point
│   │   │   └── NavigationManager.qml     # Navigation logic
│   └── ViewModel/                        # ViewModels connecting Models and Views
│       ├── AdminViewModel.cpp/hpp        # Admin logic
│       ├── AuthViewModel.cpp/hpp         # Authentication logic
│       ├── PlaylistViewModel.cpp/hpp     # Playlist logic
│       ├── SongViewModel.cpp/hpp         # Media file logic
│       └── CMakeLists.txt                # ViewModel build configuration
└── CMakeLists.txt                        # Root build configuration
```

### Key Components

- **Model**: Handles data and business logic (`PlaylistModel`, `SongModel`).
- **View**: QML files for UI, organized by user roles and functionalities.
- **ViewModel**: C++ classes that connect Models to Views, managing application logic.
- **Assets**: Stores resources like images and icons.

## Building and Running

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/dihnhuunam/Media-Player-MVVM.git
   cd Media-Player-MVVM
   ```

2. **Create a Build Directory**:

   ```bash
   mkdir build
   cd build
   ```

3. **Configure and Build**:

   ```bash
   cmake ..
   make
   ```

4. **Run the Application**:
   ```bash
   ./MediaPlayer
   ```

### Notes

- Ensure **Qt 6.8.2+** and **CMake 3.16+** are installed.
- On non-Linux systems, additional configuration may be required for Qt and CMake.
- Verify that your system meets the runtime requirements (e.g., OpenGL, audio device).

## Usage

1. **Launch the Application**:
   Run `./MediaPlayer` from the build directory.

2. **Authentication**:

   - Register a new account or log in with existing credentials.
   - Admin accounts have access to user and media management features.

3. **User Interface**:

   - Browse and play media files.
   - Create and manage playlists.
   - Customize your profile and settings.

4. **Admin Interface**:
   - Access the admin dashboard to manage users and media.
   - Upload new media files or edit existing ones.
   - Control user roles and permissions.
