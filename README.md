# Media-Player-MVVM
```
MediaPlayer/
├── Source/
│   ├── Model/
│   │   ├── AuthModel.hpp/cpp             # Xử lý đăng nhập, đăng ký
│   │   ├── PlaylistModel.hpp/cpp         # Xử lý playlist
│   │   ├── SongModel.hpp/cpp             # Xử lý bài hát và tìm kiếm
│   │
│   ├── View/
│   │   ├── Components/
│   │   │   ├── HoverButton.qml           # Thành phần giao diện tùy chỉnh
│   │   │
│   │   ├── LoginView.qml                 # Giao diện đăng nhập 
│   │   ├── RegisterView.qml              # Giao diện đăng ký 
│   │   ├── PlaylistView.qml              # Giao diện danh sách playlist 
│   │   ├── MediaFileView.qml             # Giao diện danh sách bài hát 
│   │   ├── MediaPlayerView.qml           # Giao diện phát nhạc 
│   │   ├── Main.qml                      # Main
│   │   ├── NavigationManager.qml         # Quản lý điều hướng
│   │
│   ├── ViewModel/
│   │   ├── AuthViewModel.hpp/cpp         # ViewModel cho đăng nhập, đăng ký
│   │   ├── PlaylistViewModel.hpp/cpp     # ViewModel cho danh sách playlist
│   │   ├── SongViewModel.hpp/cpp         # ViewModel cho bài hát và phát nhạc
│   │
│   ├── main.cpp                          # Entry Point
```