#include "PlaylistViewModel.hpp"
#include "AppState.hpp"
#include <QDebug>

PlaylistViewModel::PlaylistViewModel(QObject *parent)
    : QObject(parent), m_playlistModel(new PlaylistModel(this))
{
    connect(m_playlistModel, &PlaylistModel::errorOccurred,
            this, &PlaylistViewModel::handleError);
    connect(m_playlistModel, &PlaylistModel::playlistCreated,
            this, &PlaylistViewModel::onPlaylistCreated);
    connect(m_playlistModel, &PlaylistModel::playlistUpdated,
            this, &PlaylistViewModel::onPlaylistUpdated);
    connect(m_playlistModel, &PlaylistModel::playlistDeleted,
            this, &PlaylistViewModel::onPlaylistDeleted);
    connect(m_playlistModel, &PlaylistModel::songAdded,
            this, &PlaylistViewModel::onSongAdded);
    connect(m_playlistModel, &PlaylistModel::songRemoved,
            this, &PlaylistViewModel::onSongRemoved);
    connect(m_playlistModel, &PlaylistModel::songsLoaded,
            this, &PlaylistViewModel::onSongsLoaded);
    connect(m_playlistModel, &PlaylistModel::searchResultsLoaded,
            this, &PlaylistViewModel::onSearchResultsLoaded);
    connect(m_playlistModel, &PlaylistModel::songSearchResultsLoaded,
            this, &PlaylistViewModel::onSongSearchResultsLoaded);
}

PlaylistViewModel::~PlaylistViewModel()
{
}

void PlaylistViewModel::loadPlaylists()
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Vui lòng đăng nhập để tải danh sách phát");
        qDebug() << "PlaylistViewModel: Người dùng chưa đăng nhập";
        return;
    }
    m_playlistModel->loadUserPlaylists();
}

void PlaylistViewModel::createNewPlaylist(const QString &name)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Vui lòng đăng nhập để tạo danh sách phát");
        qDebug() << "PlaylistViewModel: Người dùng chưa đăng nhập";
        return;
    }
    m_playlistModel->createPlaylist(name);
}

void PlaylistViewModel::updatePlaylist(int playlistId, const QString &name)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Vui lòng đăng nhập để cập nhật danh sách phát");
        qDebug() << "PlaylistViewModel: Người dùng chưa đăng nhập";
        return;
    }
    m_playlistModel->updatePlaylist(playlistId, name);
}

void PlaylistViewModel::deletePlaylist(int playlistId)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Vui lòng đăng nhập để xóa danh sách phát");
        qDebug() << "PlaylistViewModel: Người dùng chưa đăng nhập";
        return;
    }
    m_playlistModel->deletePlaylist(playlistId);
}

void PlaylistViewModel::addSongToPlaylist(int playlistId, int songId)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Vui lòng đăng nhập để thêm bài hát vào danh sách phát");
        qDebug() << "PlaylistViewModel: Người dùng chưa đăng nhập";
        return;
    }
    m_playlistModel->addSongToPlaylist(playlistId, songId);
}

void PlaylistViewModel::removeSongFromPlaylist(int playlistId, int songId)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Vui lòng đăng nhập để xóa bài hát khỏi danh sách phát");
        qDebug() << "PlaylistViewModel: Người dùng chưa đăng nhập";
        return;
    }
    m_playlistModel->removeSongFromPlaylist(playlistId, songId);
}

void PlaylistViewModel::loadSongsInPlaylist(int playlistId)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Vui lòng đăng nhập để tải bài hát trong danh sách phát");
        qDebug() << "PlaylistViewModel: Người dùng chưa đăng nhập";
        return;
    }
    m_playlistModel->loadSongsInPlaylist(playlistId);
}

void PlaylistViewModel::search(const QString &query)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Vui lòng đăng nhập để tìm kiếm danh sách phát");
        qDebug() << "PlaylistViewModel: Người dùng chưa đăng nhập";
        return;
    }
    m_playlistModel->search(query);
}

void PlaylistViewModel::searchSongsInPlaylist(int playlistId, const QString &query)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Vui lòng đăng nhập để tìm kiếm bài hát trong danh sách phát");
        qDebug() << "PlaylistViewModel: Người dùng chưa đăng nhập";
        return;
    }
    m_playlistModel->searchSongsInPlaylist(playlistId, query);
}

void PlaylistViewModel::handleError(const QString &error)
{
    m_errorMessage = error;
    emit errorMessageChanged();
    emit errorOccurred(error);
    qDebug() << "PlaylistViewModel: Lỗi xảy ra -" << error;
}

void PlaylistViewModel::onPlaylistCreated(int playlistId)
{
    emit playlistCreated(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Đã tạo danh sách phát, ID:" << playlistId;
}

void PlaylistViewModel::onPlaylistUpdated(int playlistId)
{
    emit playlistUpdated(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Đã cập nhật danh sách phát, ID:" << playlistId;
}

void PlaylistViewModel::onPlaylistDeleted(int playlistId)
{
    emit playlistDeleted(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Đã xóa danh sách phát, ID:" << playlistId;
}

void PlaylistViewModel::onSongAdded(int playlistId)
{
    emit songAddedToPlaylist(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Đã thêm bài hát vào danh sách phát, ID:" << playlistId;
}

void PlaylistViewModel::onSongRemoved(int playlistId)
{
    emit songRemovedFromPlaylist(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Đã xóa bài hát khỏi danh sách phát, ID:" << playlistId;
}

void PlaylistViewModel::onSongsLoaded(int playlistId, const QList<SongData> &songs, const QString &message)
{
    QVariantList songList;
    for (const SongData &song : songs)
    {
        QVariantMap songMap;
        songMap["id"] = song.id;
        songMap["title"] = song.title;
        songMap["artists"] = song.artists;
        songMap["file_path"] = song.filePath;
        songMap["genres"] = song.genres;
        songList.append(songMap);
    }
    emit songsLoaded(playlistId, songList, message);
    qDebug() << "PlaylistViewModel: Đã tải bài hát cho danh sách phát" << playlistId << ", số lượng:" << songList.count();
}

void PlaylistViewModel::onSearchResultsLoaded(const QList<PlaylistData> &playlists, const QString &message)
{
    QVariantList playlistList;
    for (const PlaylistData &playlist : playlists)
    {
        QVariantMap playlistMap;
        playlistMap["id"] = playlist.id;
        playlistMap["name"] = playlist.name;
        playlistMap["imageUrl"] = playlist.imageUrl;
        playlistMap["userId"] = playlist.userId;
        playlistList.append(playlistMap);
    }
    emit searchResultsLoaded(playlistList, message);
    qDebug() << "PlaylistViewModel: Đã tải kết quả tìm kiếm danh sách phát, số lượng:" << playlistList.count();
}

void PlaylistViewModel::onSongSearchResultsLoaded(int playlistId, const QList<SongData> &songs, const QString &message)
{
    QVariantList songList;
    for (const SongData &song : songs)
    {
        QVariantMap songMap;
        songMap["id"] = song.id;
        songMap["title"] = song.title;
        songMap["artists"] = song.artists;
        songMap["file_path"] = song.filePath;
        songMap["genres"] = song.genres;
        songList.append(songMap);
    }
    emit songSearchResultsLoaded(playlistId, songList, message);
    qDebug() << "PlaylistViewModel: Đã tải kết quả tìm kiếm bài hát cho danh sách phát" << playlistId << ", số lượng:" << songList.count();
}