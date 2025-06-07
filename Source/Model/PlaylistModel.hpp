#ifndef PLAYLISTMODEL_H
#define PLAYLISTMODEL_H

#include <QAbstractListModel>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QSettings>
#include "SongModel.hpp"

struct PlaylistData
{
    int id;
    QString name;
    QList<SongData> songs;
    QString imageUrl;
    int userId;
};

class PageSongModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit PageSongModel(QObject *parent = nullptr);

    enum SongRoles
    {
        IdRole = Qt::UserRole + 1,
        TitleRole,
        ArtistsRole,
        FilePathRole,
        GenresRole
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void setSongs(const QList<SongData> &songs);
    Q_INVOKABLE void clear();

private:
    QList<SongData> m_songs;
};

class PlaylistModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY playlistsChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(int currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)
    Q_PROPERTY(int totalPages READ totalPages NOTIFY totalPagesChanged)
    Q_PROPERTY(int itemsPerPage READ itemsPerPage WRITE setItemsPerPage NOTIFY itemsPerPageChanged)
    Q_PROPERTY(PageSongModel *pageSongModel READ pageSongModel CONSTANT)
    Q_PROPERTY(PageSongModel *searchSongModel READ searchSongModel CONSTANT)

public:
    explicit PlaylistModel(QObject *parent = nullptr);

    enum PlaylistRoles
    {
        IdRole = Qt::UserRole + 1,
        NameRole,
        SongsRole,
        ImageUrlRole,
        UserIdRole
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool isLoading() const { return m_isLoading; }
    bool isAuthenticated() const;

    int currentPage() const { return m_currentPage; }
    int totalPages() const { return m_totalPages; }
    int itemsPerPage() const { return m_itemsPerPage; }
    PageSongModel *pageSongModel() const { return m_pageSongModel; }
    PageSongModel *searchSongModel() const { return m_searchSongModel; }

    Q_INVOKABLE void setCurrentPage(int page);
    Q_INVOKABLE void setItemsPerPage(int items);
    Q_INVOKABLE void loadUserPlaylists();
    Q_INVOKABLE void createPlaylist(const QString &name);
    Q_INVOKABLE void updatePlaylist(int playlistId, const QString &name);
    Q_INVOKABLE void addSongToPlaylist(int playlistId, int songId);
    Q_INVOKABLE void removeSongFromPlaylist(int playlistId, int songId);
    Q_INVOKABLE void deletePlaylist(int playlistId);
    Q_INVOKABLE void loadSongsInPlaylist(int playlistId);
    Q_INVOKABLE void search(const QString &query, int limit = 10, int offset = 0);
    Q_INVOKABLE void searchSongsInPlaylist(int playlistId, const QString &query, int limit = 10, int offset = 0);

signals:
    void playlistsChanged();
    void songsLoaded(int playlistId, const QList<SongData> &songs, const QString &message);
    void searchResultsLoaded(const QList<PlaylistData> &playlists, const QString &message);
    void songSearchResultsLoaded(int playlistId, const QList<SongData> &songs, const QString &message);
    void errorOccurred(const QString &error);
    void isLoadingChanged();
    void playlistCreated(int playlistId);
    void playlistUpdated(int playlistId);
    void playlistDeleted(int playlistId);
    void songAdded(int playlistId);
    void songRemoved(int playlistId, int songId);
    void currentPageChanged();
    void totalPagesChanged();
    void itemsPerPageChanged();

private slots:
    void handleNetworkReply(QNetworkReply *reply, int playlistId = 0, int songId = 0);

private:
    void updatePageSongs();
    QList<PlaylistData> m_playlists;
    QNetworkAccessManager m_networkManager;
    QSettings *m_settings;
    bool m_isLoading = false;
    int m_currentPage = 0;
    int m_totalPages = 0;
    int m_itemsPerPage = 25;
    QList<SongData> m_currentSongs;
    PageSongModel *m_pageSongModel;
    PageSongModel *m_searchSongModel;
};

#endif // PLAYLISTMODEL_H