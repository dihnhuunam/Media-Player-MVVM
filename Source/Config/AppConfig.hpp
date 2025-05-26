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
    QString getSongsEndpoint() const;
    QString getSongsSearchEndpoint() const;
    QString getSongsStreamEndpoint(int songId) const;
    QString getPlaylistsEndpoint() const;
    QString getPlaylistEndpoint(int playlistId) const;
    QString getPlaylistsSongsEndpoint() const;
    QString getPlaylistSongsEndpoint(int playlistId) const;
    QString getPlaylistSongEndpoint(int playlistId, int songId) const;
    QString getPlaylistsSearchEndpoint() const;
    QString getPlaylistSongsSearchEndpoint(int playlistId) const; // Thêm endpoint tìm kiếm bài hát trong playlist

private:
    AppConfig() = default;
    QMap<QString, QString> envVariables;
};