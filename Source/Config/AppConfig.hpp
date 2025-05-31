#pragma once
#include <QString>
#include <QMap>

class AppConfig
{
public:
    static AppConfig &instance();
    bool loadEnvFile(const QString &filePath);

    QString getBaseUrl() const;
    QString getAuthLoginEndpoint() const;
    QString getAuthRegisterEndpoint() const;
    QString getAuthUpdateEndpoint(int userId) const;
    QString getAuthGetUsersEndpoint() const;
    QString getAuthGetUserByIdEndpoint(int userId) const;
    QString getAuthSearchUsersByNameEndpoint() const;
    QString getSongsEndpoint() const;
    QString getSongsSearchEndpoint() const;
    QString getSongsStreamEndpoint(int songId) const;
    QString getSongsSearchByGenresEndpoint() const;
    QString getSongsUpdateEndpoint(int songId) const;
    QString getSongsDeleteEndpoint(int songId) const;
    QString getSongByIdEndpoint(int songId) const;
    QString getPlaylistsEndpoint() const;
    QString getPlaylistEndpoint(int playlistId) const;
    QString getPlaylistsSongsEndpoint() const;
    QString getPlaylistSongsEndpoint(int playlistId) const;
    QString getPlaylistSongEndpoint(int playlistId, int songId) const;
    QString getPlaylistsSearchEndpoint() const;
    QString getPlaylistSongsSearchEndpoint(int playlistId) const;
    QString getPlaylistsCreateEndpoint() const;
    QString getPlaylistsGetUserPlaylistsEndpoint() const;
    QString getPlaylistsAddSongEndpoint() const;
    QString getPlaylistsUpdateNameEndpoint(int playlistId) const;
    QString getPlaylistsRemoveSongEndpoint() const;
    QString getPlaylistsDeleteEndpoint(int playlistId) const;

private:
    AppConfig() = default;
    QMap<QString, QString> envVariables;
};