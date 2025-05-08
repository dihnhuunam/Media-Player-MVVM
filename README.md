# Media-Player-MVVM
```
MediaPlayer/
├── Source/
│   ├── Model/
│   │   ├── AuthModel.hpp/cpp             # Xử lý đăng nhập, đăng ký
│   │   ├── PlaylistModel.hpp/cpp         # Xử lý playlist
│   │   ├── SongModel.hpp/cpp             # Xử lý bài hát và tìm kiếm
│   │   ├── AppState.hpp/cpp              # Quản lý trạng thái ứng dụng (thay thế AppState.qml)
│   │
│   ├── View/
│   │   ├── Components/
│   │   │   ├── HoverButton.qml           # Thành phần giao diện tùy chỉnh
│   │   │
│   │   ├── LoginView.qml                 # Giao diện đăng nhập (cập nhật)
│   │   ├── RegisterView.qml              # Giao diện đăng ký (cập nhật)
│   │   ├── PlaylistView.qml              # Giao diện danh sách playlist (cập nhật)
│   │   ├── MediaFileView.qml             # Giao diện danh sách bài hát (cập nhật)
│   │   ├── MediaPlayerView.qml           # Giao diện phát nhạc (cập nhật)
│   │   ├── Main.qml                      # Tệp chính cho ứng dụng
│   │   ├── NavigationManager.qml         # Quản lý điều hướng
│   │
│   ├── ViewModel/
│   │   ├── AuthViewModel.hpp/cpp         # ViewModel cho đăng nhập, đăng ký
│   │   ├── PlaylistViewModel.hpp/cpp     # ViewModel cho danh sách playlist
│   │   ├── SongViewModel.hpp/cpp         # ViewModel cho bài hát và phát nhạc
│   │
│   ├── main.cpp                          # Điểm vào chương trình
```