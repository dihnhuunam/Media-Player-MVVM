#include "PlaylistViewModel.hpp"
#include <QSettings>
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

bool PlaylistViewModel::isAuthenticated() const
{
    QSettings settings("MediaPlayer", "Auth");
    QString token = settings.value("jwt_token", "").toString();
    return !token.isEmpty();
}

void PlaylistViewModel::loadPlaylists()
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to load playlists");
        qDebug() << "PlaylistViewModel: User not authenticated";
        return;
    }
    m_playlistModel->loadUserPlaylists();
}

void PlaylistViewModel::createNewPlaylist(const QString &name)
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to create a playlist");
        qDebug() << "PlaylistViewModel: User not authenticated";
        return;
    }
    m_playlistModel->createPlaylist(name);
}

void PlaylistViewModel::updatePlaylist(int playlistId, const QString &name)
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to update a playlist");
        qDebug() << "PlaylistViewModel: User not authenticated";
        return;
    }
    m_playlistModel->updatePlaylist(playlistId, name);
}

void PlaylistViewModel::deletePlaylist(int playlistId)
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to delete a playlist");
        qDebug() << "PlaylistViewModel: User not authenticated";
        return;
    }
    m_playlistModel->deletePlaylist(playlistId);
}

void PlaylistViewModel::addSongToPlaylist(int playlistId, int songId)
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to add a song to playlist");
        qDebug() << "PlaylistViewModel: User not authenticated";
        return;
    }
    m_playlistModel->addSongToPlaylist(playlistId, songId);
}

void PlaylistViewModel::removeSongFromPlaylist(int playlistId, int songId)
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to remove a song from playlist");
        qDebug() << "PlaylistViewModel: User not authenticated";
        return;
    }
    m_playlistModel->removeSongFromPlaylist(playlistId, songId);
}

void PlaylistViewModel::loadSongsInPlaylist(int playlistId)
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to load songs in playlist");
        qDebug() << "PlaylistViewModel: User not authenticated";
        return;
    }
    m_playlistModel->loadSongsInPlaylist(playlistId);
}

void PlaylistViewModel::handleError(const QString &error)
{
    m_errorMessage = error;
    emit errorMessageChanged();
    emit errorOccurred(error);
    qDebug() << "PlaylistViewModel: Error -" << error;
}

void PlaylistViewModel::onPlaylistCreated(int playlistId)
{
    emit playlistCreated(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Playlist created, ID:" << playlistId;
}

void PlaylistViewModel::onPlaylistUpdated(int playlistId)
{
    emit playlistUpdated(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Playlist updated, ID:" << playlistId;
}

void PlaylistViewModel::onPlaylistDeleted(int playlistId)
{
    emit playlistDeleted(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Playlist deleted, ID:" << playlistId;
}

void PlaylistViewModel::onSongAdded(int playlistId)
{
    emit songAddedToPlaylist(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Song added to playlist, ID:" << playlistId;
}

void PlaylistViewModel::onSongRemoved(int playlistId)
{
    emit songRemovedFromPlaylist(playlistId);
    loadPlaylists();
    qDebug() << "PlaylistViewModel: Song removed from playlist, ID:" << playlistId;
}

void PlaylistViewModel::onSongsLoaded(int playlistId, const QList<SongData> &songs, const QString &message)
{
    emit songsLoaded(playlistId, songs, message);
    qDebug() << "PlaylistViewModel: Songs loaded for playlist" << playlistId << ", count:" << songs.count();
}