# Media Player MVVM

A modern, feature-rich media player application built with **Qt Quick/QML** and **C++** using the **MVVM (Model-View-ViewModel)** architecture. This application provides a seamless user experience for media playback, playlist management, user authentication, and admin functionalities, with a focus on modularity, scalability, and a responsive user interface.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [System Requirements](#system-requirements)
- [Project Structure](#project-structure)
- [Building and Running](#building-and-running)
- [Usage](#usage)

## Overview

The Media Player MVVM is designed to deliver a robust and intuitive media playback experience. Leveraging the power of **Qt Quick/QML** for the frontend and **C++** for backend logic, the application adheres to the **MVVM** architectural pattern to ensure a clear separation of concerns. It supports both regular users, who can enjoy media playback and playlist management, and administrators, who can manage users and media content. The project is primarily developed for Linux but can be adapted for other platforms with additional configuration.

## Features

### User Features

- **Media Playback**:
  - Intuitive controls for play, pause, stop, next, and previous tracks.
  - Adjustable volume with a mute option.
  - Seek slider for precise navigation within tracks.
  - Repeat modes (single track or entire playlist) and shuffle playback.
- **Playlist Management**:
  - Create, edit, and delete custom playlists.
  - Add, remove, and reorder tracks within playlists.
  - View detailed playlist information, including track count and duration.
- **Profile Management**:
  - View and update user profile details.
  - Customize player settings, such as themes and playback preferences.
  - Access a history of recently played tracks.

### Admin Features

- **User Management**:
  - View a list of all registered users.
  - Assign or modify user roles (admin or regular user).
  - Enable or disable user accounts for access control.
- **Media Management**:
  - Upload new audio or video files to the media library.
  - Edit metadata for media files (e.g., title, artist, album).
  - Remove outdated or unwanted media files.
  - Set access permissions for specific media files.

### Technical Features

- Modern, responsive UI built with **Qt Quick/QML** for a smooth user experience.
- **MVVM architecture** for maintainable and testable code.
- Efficient media processing using **Qt Multimedia** for playback and metadata handling.
- Persistent storage for user profiles, playlists, and settings.
- Event-driven design for real-time UI updates and interactions.
- Role-based access control to secure admin and user functionalities.

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
├── Assets/
├── Source/
│   ├── Model/
│   │   ├── Admin/
│   │   │   ├── AdminModel.hpp
│   │   │   └── AdminModel.cpp
│   │   ├── Authentication/
│   │   │   ├── AuthModel.hpp
│   │   │   └── AuthModel.cpp
│   │   ├── Client/
│   │   │   ├── PlaylistModel.hpp
│   │   │   ├── PlaylistModel.cpp
│   │   │   ├── SongModel.hpp
│   │   │   ├── SongModel.cpp
│   │   │   ├── UartModel.hpp
│   │   │   ├── UartModel.cpp
│   ├── View/
│   │   ├── Admin/
│   │   │   ├── AdminDashboard.qml
│   │   │   ├── AdminMediaFilesView.qml
│   │   │   ├── AdminUploadFile.qml
│   │   │   └── AdminViewUsers.qml
│   │   ├── Authentication/
│   │   │   ├── LoginView.qml
│   │   │   └── RegisterView.qml
│   │   ├── Client/
│   │   │   ├── AddSong.qml
│   │   │   ├── MediaFileView.qml
│   │   │   ├── MediaPlayerView.qml
│   │   │   ├── PlaylistView.qml
│   │   │   └── ProfileView.qml
│   │   ├── Components/
│   │   │   ├── HoverButton.qml
│   │   │   └── SliderComponent.qml
│   │   ├── Helper/
│   │   │   └── NavigationManager.qml
│   │   ├── Main.qml
│   │   ├── ViewModel/
│   │   │   ├── PlaylistViewModel.hpp
│   │   │   ├── PlaylistViewModel.cpp
│   │   │   ├── SongViewModel.hpp
│   │   │   ├── SongViewModel.cpp
│   │   │   ├── UartViewModel.hpp
│   │   │   ├── UartViewModel.cpp
```

### Key Components

- **Model**: Manages data and business logic, including playlist and song handling (`PlaylistModel`, `SongModel`).
- **View**: QML files define the user interface, organized by user roles (Admin, Client) and functionalities (Authentication, Playback).
- **ViewModel**: C++ classes that act as intermediaries between Models and Views, handling application logic and data binding.
- **Assets**: Stores static resources like images, icons, and other media used in the UI.

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

- Ensure **Qt 6.8.2** (or higher) and **CMake 3.16+** are installed.
- Non-Linux systems may require additional configuration for Qt and CMake.
- Verify that runtime requirements (e.g., OpenGL, audio device) are met.

## Usage

1. **Launch the Application**:
   Execute `./MediaPlayer` from the build directory.

2. **Authentication**:

   - Register a new account or log in with existing credentials.
   - Admin accounts unlock access to user and media management features.

3. **User Interface**:

   - Browse and play media files from the library.
   - Create, edit, and manage playlists.
   - Customize profile settings and view playback history.

4. **Admin Interface**:
   - Access the admin dashboard to oversee users and media.
   - Upload or edit media files and manage metadata.
   - Assign user roles and control account access.
