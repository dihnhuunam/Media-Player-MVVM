# Media Player MVVM

A modern media player application built with Qt Quick/QML and C++ following the MVVM (Model-View-ViewModel) architecture pattern.

## System Requirements

### Build Requirements

- Qt 6.8.2 or higher
- CMake 3.16 or higher
- C++17 compatible compiler
- Qt Quick and Qt Multimedia modules

### Runtime Requirements

- Operating System: Linux (Primary support)
- Minimum RAM: 4GB
- Storage: 100MB free space
- Graphics: OpenGL 2.0 compatible graphics card
- Audio: Working sound card/audio device

## Project Structure

The project follows the MVVM architecture pattern with a clear separation of concerns. Below is the detailed structure based on the source files:

```
Media-Player-MVVM/
├── Source/                               # Source code root
│   ├── Model/                            # Data models and business logic
│   │   ├── CMakeLists.txt                # Build configuration for models
│   │   ├── PlaylistModel.cpp             # Playlist management logic
│   │   ├── PlaylistModel.hpp             # Playlist model header
│   │   ├── SongModel.cpp                 # Media file handling logic
│   │   └── SongModel.hpp                 # Song model header
│   ├── View/                             # QML UI files
│   │   ├── Admin/                        # Admin interface views
│   │   │   ├── AdminDashboard.qml        # Admin dashboard UI
│   │   │   ├── AdminMediaFilesView.qml   # View for managing media files
│   │   │   └── AdminUploadFile.qml       # UI for uploading media files
│   │   ├── Authentication/               # Login/Register views
│   │   │   ├── LoginView.qml             # Login UI
│   │   │   └── RegisterView.qml          # Registration UI
│   │   ├── Client/                       # Main player interface
│   │   │   ├── MediaFileView.qml         # Media file browsing UI
│   │   │   ├── MediaPlayerView.qml       # Media player UI
│   │   │   ├── PlaylistView.qml          # Playlist viewing UI
│   │   │   └── ProfileView.qml           # User profile UI
│   │   ├── Components/                   # Reusable UI components
│   │   │   ├── HoverButton.qml           # Custom button with hover effect
│   │   │   └── SliderComponent.qml       # Custom slider for media seeking/volume
│   │   └── Helper/                       # UI utilities
│   │       ├── NavigationManager.qml     # Navigation logic for UI
│   │       └── Main.qml                  # Main QML entry point
│   └── ViewModel/                        # ViewModels connecting Models and Views
│       ├── AdminViewModel.cpp            # Admin ViewModel
│       ├── AdminViewModel.hpp            # Admin ViewModel header
│       ├── AuthViewModel.cpp             # Authentication ViewModel
│       ├── AuthViewModel.hpp             # Authentication ViewModel header
│       ├── CMakeLists.txt                # Build configuration for ViewModels
│       ├── PlaylistViewModel.cpp         # Playlist ViewModel
│       ├── PlaylistViewModel.hpp         # Playlist ViewModel header
│       ├── SongViewModel.cpp             # Song ViewModel
│       └── SongViewModel.hpp             # Song ViewModel header
├── Assets/                               # Application resources
└── CMakeLists.txt                        # Root build configuration
```

### Notes on Structure:

- **Model/**: Contains the data models (`PlaylistModel` and `SongModel`) with their respective C++ source and header files, along with a `CMakeLists.txt` for building the model layer.
- **View/**: Organized into subdirectories for different UI sections:
  - `Admin/` for admin-specific views like dashboards and media management.
  - `Authentication/` for login and registration UIs.
  - `Client/` for the main user interface, including media playback and playlist management.
  - `Components/` for reusable QML components like buttons and sliders.
  - `Helper/` for utility QML files, including the main entry point (`Main.qml`) and navigation logic.
- **ViewModel/**: Contains the ViewModels that connect the Models to the Views, with separate C++ files for admin, authentication, playlist, and song functionalities.
- The root `CMakeLists.txt` manages the overall build configuration.

## Features and Usage

### Authentication

- User registration with email and password
- Secure login system
- Role-based access control (Admin/User)

### User Features

- Media Playback

  - Play/Pause/Stop controls
  - Next/Previous track navigation
  - Volume control with mute option
  - Seek functionality
  - Repeat modes (Single/All)
  - Shuffle mode

- Playlist Management

  - Create and manage multiple playlists
  - Add/Remove tracks
  - Reorder tracks
  - View playlist details

- Profile Management
  - View and edit user profile
  - Customize player settings
  - View playback history

### Admin Features

- User Management

  - View all users
  - Manage user roles
  - Disable/Enable accounts

- Media Management
  - Upload new media files
  - Edit media metadata
  - Remove media files
  - Manage file access permissions

### Technical Features

- Modern QML/Qt Quick UI
- MVVM Architecture
- Responsive design
- Efficient media handling
- Persistent storage
- Event-driven architecture

## Building and Running

1. Clone the repository:

```bash
git clone https://github.com/dihnhuunam/Media-Player-MVVM.git
cd Media-Player-MVVM
```

2. Create build directory:

```bash
mkdir build
cd build
```

3. Configure and build:

```bash
cmake ..
make
```

4. Run the application:

```bash
./MediaPlayer
```
