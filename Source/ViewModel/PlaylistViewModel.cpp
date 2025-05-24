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
}

PlaylistViewModel::~PlaylistViewModel()
{
}

void PlaylistViewModel::loadPlaylists()
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please login to load playlists");
        qDebug() << "PlaylistViewModel: User is not authenticated";
        return;
    }
    m_playlistModel->loadUserPlaylists();
}

void PlaylistViewModel::createNewPlaylist(const QString &name)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please login to create a playlist");
        qDebug() << "PlaylistViewModel: User is not authenticated";
        return;
    }
    m_playlistModel->createPlaylist(name);
}

void PlaylistViewModel::updatePlaylist(int playlistId, const QString &name)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please login to update a playlist");
        qDebug() << "PlaylistViewModel: User is not authenticated";
        return;
    }
    m_playlistModel->updatePlaylist(playlistId, name);
}

void PlaylistViewModel::deletePlaylist(int playlistId)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please login to delete a playlist");
        qDebug() << "PlaylistViewModel: User is not authenticated";
        return;
    }
    m_playlistModel->deletePlaylist(playlistId);
}

void PlaylistViewModel::addSongToPlaylist(int playlistId, int songId)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please login to add a song to playlist");
        qDebug() << "PlaylistViewModel: User is not authenticated";
        return;
    }
    m_playlistModel->addSongToPlaylist(playlistId, songId);
}

void PlaylistViewModel::removeSongFromPlaylist(int playlistId, int songId)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please login to remove a song from playlist");
        qDebug() << "PlaylistViewModel: User is not authenticated";
        return;
    }
    m_playlistModel->removeSongFromPlaylist(playlistId, songId);
}

void PlaylistViewModel::loadSongsInPlaylist(int playlistId)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please login to load songs in playlist");
        qDebug() << "PlaylistViewModel: User is not authenticated";
        return;
    }
    m_playlistModel->loadSongsInPlaylist(playlistId);
}

void PlaylistViewModel::handleError(const QString &error)
{
    m_errorMessage = error;
    emit errorMessageChanged();
    emit errorOccurred(error);
    qDebug() << "PlaylistViewModel: Error occurred -" << error;
}

void PlaylistViewModel::onPlaylistCreated(int playlistId)
{
    emit playlistCreated(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Created playlist, ID:" << playlistId;
}

void PlaylistViewModel::onPlaylistUpdated(int playlistId)
{
    emit playlistUpdated(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Updated playlist, ID:" << playlistId;
}

void PlaylistViewModel::onPlaylistDeleted(int playlistId)
{
    emit playlistDeleted(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Deleted playlist, ID:" << playlistId;
}

void PlaylistViewModel::onSongAdded(int playlistId)
{
    emit songAddedToPlaylist(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Added song to playlist, ID:" << playlistId;
}

void PlaylistViewModel::onSongRemoved(int playlistId)
{
    emit songRemovedFromPlaylist(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Removed song from playlist, ID:" << playlistId;
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
    qDebug() << "PlaylistViewModel: Loaded songs for playlist" << playlistId << ", count:" << songList.count();
}