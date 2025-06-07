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
    connect(m_playlistModel, &PlaylistModel::currentPageChanged,
            this, &PlaylistViewModel::currentPageChanged);
    connect(m_playlistModel, &PlaylistModel::totalPagesChanged,
            this, &PlaylistViewModel::totalPagesChanged);
    connect(m_playlistModel, &PlaylistModel::itemsPerPageChanged,
            this, &PlaylistViewModel::itemsPerPageChanged);
}

PlaylistViewModel::~PlaylistViewModel()
{
}

void PlaylistViewModel::setSearchLimit(int limit)
{
    if (m_searchLimit != limit)
    {
        m_searchLimit = limit;
        emit searchLimitChanged();
        qDebug() << "PlaylistViewModel: Search limit set to" << limit;
    }
}

void PlaylistViewModel::setSearchOffset(int offset)
{
    if (m_searchOffset != offset)
    {
        m_searchOffset = offset;
        emit searchOffsetChanged();
        qDebug() << "PlaylistViewModel: Search offset set to" << offset;
    }
}

void PlaylistViewModel::setCurrentPage(int page)
{
    m_playlistModel->setCurrentPage(page);
}

void PlaylistViewModel::setItemsPerPage(int items)
{
    m_playlistModel->setItemsPerPage(items);
}

void PlaylistViewModel::loadPlaylists()
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please log in to load playlists");
        qDebug() << "PlaylistViewModel: User is not logged in";
        return;
    }
    m_playlistModel->loadUserPlaylists();
}

void PlaylistViewModel::createNewPlaylist(const QString &name)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please log in to create a playlist");
        qDebug() << "PlaylistViewModel: User is not logged in";
        return;
    }
    m_playlistModel->createPlaylist(name);
}

void PlaylistViewModel::updatePlaylist(int playlistId, const QString &name)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please log in to update a playlist");
        qDebug() << "PlaylistViewModel: User is not logged in";
        return;
    }
    m_playlistModel->updatePlaylist(playlistId, name);
}

void PlaylistViewModel::deletePlaylist(int playlistId)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please log in to delete a playlist");
        qDebug() << "PlaylistViewModel: User is not logged in";
        return;
    }
    m_playlistModel->deletePlaylist(playlistId);
}

void PlaylistViewModel::addSongToPlaylist(int playlistId, int songId)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please log in to add a song to a playlist");
        qDebug() << "PlaylistViewModel: User is not logged in";
        return;
    }
    m_playlistModel->addSongToPlaylist(playlistId, songId);
}

void PlaylistViewModel::removeSongFromPlaylist(int playlistId, int songId)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please log in to remove a song from a playlist");
        qDebug() << "PlaylistViewModel: User is not logged in";
        return;
    }
    m_playlistModel->removeSongFromPlaylist(playlistId, songId);
}

void PlaylistViewModel::loadSongsInPlaylist(int playlistId)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please log in to load songs in a playlist");
        qDebug() << "PlaylistViewModel: User is not logged in";
        return;
    }
    m_playlistModel->loadSongsInPlaylist(playlistId);
}

void PlaylistViewModel::search(const QString &query)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please log in to search for playlists");
        qDebug() << "PlaylistViewModel: User is not logged in";
        return;
    }
    m_playlistModel->search(query, m_searchLimit, m_searchOffset);
}

void PlaylistViewModel::searchSongsInPlaylist(int playlistId, const QString &query)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please log in to search for songs in a playlist");
        qDebug() << "PlaylistViewModel: User is not logged in";
        return;
    }
    m_playlistModel->searchSongsInPlaylist(playlistId, query, m_searchLimit, m_searchOffset);
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

void PlaylistViewModel::onSongRemoved(int playlistId, int songId)
{
    emit songRemovedFromPlaylist(playlistId, songId);
    qDebug() << "PlaylistViewModel: Song removed from playlist, ID:" << playlistId << "Song ID:" << songId;
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
    qDebug() << "PlaylistViewModel: Songs loaded for playlist" << playlistId << ", count:" << songList.count();
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
    qDebug() << "PlaylistViewModel: Playlist search results loaded, count:" << playlistList.count();
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
    qDebug() << "PlaylistViewModel: Song search results loaded for playlist" << playlistId << ", count:" << songList.count();
}