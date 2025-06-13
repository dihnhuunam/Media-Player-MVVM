#pragma once
#include <QObject>
#include "PlaylistModel.hpp"

class PlaylistViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(PlaylistModel *playlistModel READ playlistModel CONSTANT)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(int searchLimit READ searchLimit WRITE setSearchLimit NOTIFY searchLimitChanged)
    Q_PROPERTY(int searchOffset READ searchOffset WRITE setSearchOffset NOTIFY searchOffsetChanged)
    Q_PROPERTY(int currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)
    Q_PROPERTY(int totalPages READ totalPages NOTIFY totalPagesChanged)
    Q_PROPERTY(int itemsPerPage READ itemsPerPage WRITE setItemsPerPage NOTIFY itemsPerPageChanged)

public:
    explicit PlaylistViewModel(QObject *parent = nullptr);
    ~PlaylistViewModel();

    PlaylistModel *playlistModel() const { return m_playlistModel; }
    QString errorMessage() const { return m_errorMessage; }
    int searchLimit() const { return m_searchLimit; }
    int searchOffset() const { return m_searchOffset; }
    int currentPage() const { return m_playlistModel->currentPage(); }
    int totalPages() const { return m_playlistModel->totalPages(); }
    int itemsPerPage() const { return m_playlistModel->itemsPerPage(); }

    Q_INVOKABLE void setSearchLimit(int limit);
    Q_INVOKABLE void setSearchOffset(int offset);
    Q_INVOKABLE void setCurrentPage(int page);
    Q_INVOKABLE void setItemsPerPage(int items);
    Q_INVOKABLE void loadPlaylists();
    Q_INVOKABLE void createNewPlaylist(const QString &name);
    Q_INVOKABLE void updatePlaylist(int playlistId, const QString &name);
    Q_INVOKABLE void deletePlaylist(int playlistId);
    Q_INVOKABLE void addSongToPlaylist(int playlistId, int songId);
    Q_INVOKABLE void removeSongFromPlaylist(int playlistId, int songId);
    Q_INVOKABLE void loadSongsInPlaylist(int playlistId);
    Q_INVOKABLE void search(const QString &query);
    Q_INVOKABLE void searchSongsInPlaylist(int playlistId, const QString &query);

signals:
    void errorMessageChanged();
    void errorOccurred(const QString &error);
    void playlistCreated(int playlistId);
    void playlistUpdated(int playlistId);
    void playlistDeleted(int playlistId);
    void songAddedToPlaylist(int playlistId);
    void songRemovedFromPlaylist(int playlistId, int songId);
    void songsLoaded(int playlistId, const QVariantList &songs, const QString &message);
    void searchResultsLoaded(const QVariantList &playlists, const QString &message);
    void songSearchResultsLoaded(int playlistId, const QVariantList &songs, const QString &message);
    void searchLimitChanged();
    void searchOffsetChanged();
    void currentPageChanged();
    void totalPagesChanged();
    void itemsPerPageChanged();

private slots:
    void handleError(const QString &error);
    void onPlaylistCreated(int playlistId);
    void onPlaylistUpdated(int playlistId);
    void onPlaylistDeleted(int playlistId);
    void onSongAdded(int playlistId);
    void onSongRemoved(int playlistId, int songId);
    void onSongsLoaded(int playlistId, const QList<SongData> &songs, const QString &message);
    void onSearchResultsLoaded(const QList<PlaylistData> &playlists, const QString &message);
    void onSongSearchResultsLoaded(int playlistId, const QList<SongData> &songs, const QString &message);

private:
    PlaylistModel *m_playlistModel;
    QString m_errorMessage;
    int m_searchLimit = 10;
    int m_searchOffset = 0;
};