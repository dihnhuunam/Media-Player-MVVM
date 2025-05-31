#include "AppConfig.hpp"
#include <QFile>
#include <QTextStream>
#include <QDebug>

AppConfig &AppConfig::instance()
{
    static AppConfig instance;
    return instance;
}

bool AppConfig::loadEnvFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        qDebug() << "AppConfig: Failed to open .env file at" << filePath;
        return false;
    }

    QTextStream in(&file);
    while (!in.atEnd())
    {
        QString line = in.readLine().trimmed();
        if (line.isEmpty() || line.startsWith("#"))
            continue;

        QStringList parts = line.split("=");
        if (parts.size() < 2)
            continue;

        QString key = parts[0].trimmed();
        QString value = parts.mid(1).join("=").trimmed();

        for (const auto &envKey : envVariables.keys())
        {
            value.replace("${" + envKey + "}", envVariables[envKey]);
        }
        envVariables[key] = value;
    }
    file.close();
    qDebug() << "AppConfig: Loaded .env file with" << envVariables.size() << "variables";
    return true;
}

QString AppConfig::getBaseUrl() const
{
    return envVariables.value("BASE_URL", "http://localhost:3000");
}

QString AppConfig::getAuthLoginEndpoint() const
{
    return envVariables.value("AUTH_LOGIN_ENDPOINT", getBaseUrl() + "/api/auth/login");
}

QString AppConfig::getAuthRegisterEndpoint() const
{
    return envVariables.value("AUTH_REGISTER_ENDPOINT", getBaseUrl() + "/api/auth/register");
}

QString AppConfig::getAuthUpdateEndpoint(int userId) const
{
    QString endpoint = envVariables.value("AUTH_UPDATE_ENDPOINT", getBaseUrl() + "/api/auth/users");
    QString url = endpoint + "/" + QString::number(userId);
    qDebug() << "AppConfig: Generated AUTH_UPDATE_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getAuthGetUsersEndpoint() const
{
    QString url = envVariables.value("AUTH_GET_USERS_ENDPOINT", getBaseUrl() + "/api/auth/users");
    qDebug() << "AppConfig: Generated AUTH_GET_USERS_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getAuthGetUserByIdEndpoint(int userId) const
{
    QString endpoint = envVariables.value("AUTH_GET_USER_BY_ID_ENDPOINT", getBaseUrl() + "/api/auth/users");
    QString url = endpoint + "/" + QString::number(userId);
    qDebug() << "AppConfig: Generated AUTH_GET_USER_BY_ID_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getAuthSearchUsersByNameEndpoint() const
{
    QString url = envVariables.value("AUTH_SEARCH_USERS_BY_NAME_ENDPOINT", getBaseUrl() + "/api/auth/users/search");
    qDebug() << "AppConfig: Generated AUTH_SEARCH_USERS_BY_NAME_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getSongsEndpoint() const
{
    QString url = envVariables.value("SONGS_ENDPOINT", getBaseUrl() + "/api/songs");
    qDebug() << "AppConfig: Generated SONGS_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getSongsSearchEndpoint() const
{
    QString url = envVariables.value("SONGS_SEARCH_ENDPOINT", getBaseUrl() + "/api/songs/search");
    qDebug() << "AppConfig: Generated SONGS_SEARCH_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getSongsStreamEndpoint(int songId) const
{
    QString endpoint = envVariables.value("SONGS_STREAM_ENDPOINT", getBaseUrl() + "/api/songs/stream");
    QString url = endpoint + "/" + QString::number(songId);
    qDebug() << "AppConfig: Generated SONGS_STREAM_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getSongsSearchByGenresEndpoint() const
{
    QString url = envVariables.value("SONGS_SEARCH_BY_GENRES_ENDPOINT", getBaseUrl() + "/api/songs/search-by-genres");
    qDebug() << "AppConfig: Generated SONGS_SEARCH_BY_GENRES_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getSongsUpdateEndpoint(int songId) const
{
    QString endpoint = envVariables.value("SONGS_UPDATE_ENDPOINT", getBaseUrl() + "/api/songs");
    QString url = endpoint + "/" + QString::number(songId);
    qDebug() << "AppConfig: Generated SONGS_UPDATE_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getSongsDeleteEndpoint(int songId) const
{
    QString endpoint = envVariables.value("SONGS_DELETE_ENDPOINT", getBaseUrl() + "/api/songs");
    QString url = endpoint + "/" + QString::number(songId);
    qDebug() << "AppConfig: Generated SONGS_DELETE_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getSongByIdEndpoint(int songId) const
{
    QString endpoint = envVariables.value("SONG_BY_ID_ENDPOINT", getBaseUrl() + "/api/songs");
    QString url = endpoint + "/" + QString::number(songId);
    qDebug() << "AppConfig: Generated SONG_BY_ID_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getPlaylistsEndpoint() const
{
    QString url = envVariables.value("PLAYLISTS_ENDPOINT", getBaseUrl() + "/api/playlists");
    qDebug() << "AppConfig: Generated PLAYLISTS_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getPlaylistEndpoint(int playlistId) const
{
    QString url = getPlaylistsEndpoint() + "/" + QString::number(playlistId);
    qDebug() << "AppConfig: Generated PLAYLIST_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getPlaylistsSongsEndpoint() const
{
    QString url = envVariables.value("PLAYLISTS_SONGS_ENDPOINT", getBaseUrl() + "/api/playlists/songs");
    qDebug() << "AppConfig: Generated PLAYLISTS_SONGS_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getPlaylistSongsEndpoint(int playlistId) const
{
    QString url = getPlaylistsEndpoint() + "/" + QString::number(playlistId) + "/songs";
    qDebug() << "AppConfig: Generated PLAYLIST_SONGS_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getPlaylistSongEndpoint(int playlistId, int songId) const
{
    QString url = getPlaylistSongsEndpoint(playlistId) + "/" + QString::number(songId);
    qDebug() << "AppConfig: Generated PLAYLIST_SONG_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getPlaylistsSearchEndpoint() const
{
    QString url = envVariables.value("PLAYLISTS_SEARCH_ENDPOINT", getBaseUrl() + "/api/playlists/search");
    qDebug() << "AppConfig: Generated PLAYLISTS_SEARCH_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getPlaylistSongsSearchEndpoint(int playlistId) const
{
    QString url = envVariables.value("PLAYLISTS_SEARCH_SONGS_ENDPOINT", getBaseUrl() + "/api/playlists/" + QString::number(playlistId) + "/songs/search");
    qDebug() << "AppConfig: Generated PLAYLISTS_SEARCH_SONGS_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getPlaylistsCreateEndpoint() const
{
    QString url = envVariables.value("PLAYLISTS_CREATE_ENDPOINT", getBaseUrl() + "/api/playlists");
    qDebug() << "AppConfig: Generated PLAYLISTS_CREATE_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getPlaylistsGetUserPlaylistsEndpoint() const
{
    QString url = envVariables.value("PLAYLISTS_GET_USER_PLAYLISTS_ENDPOINT", getBaseUrl() + "/api/playlists");
    qDebug() << "AppConfig: Generated PLAYLISTS_GET_USER_PLAYLISTS_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getPlaylistsAddSongEndpoint() const
{
    QString url = envVariables.value("PLAYLISTS_ADD_SONG_ENDPOINT", getBaseUrl() + "/api/playlists/songs");
    qDebug() << "AppConfig: Generated PLAYLISTS_ADD_SONG_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getPlaylistsUpdateNameEndpoint(int playlistId) const
{
    QString endpoint = envVariables.value("PLAYLISTS_UPDATE_NAME_ENDPOINT", getBaseUrl() + "/api/playlists");
    QString url = endpoint + "/" + QString::number(playlistId);
    qDebug() << "AppConfig: Generated PLAYLISTS_UPDATE_NAME_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getPlaylistsRemoveSongEndpoint() const
{
    QString url = envVariables.value("PLAYLISTS_REMOVE_SONG_ENDPOINT", getBaseUrl() + "/api/playlists/songs");
    qDebug() << "AppConfig: Generated PLAYLISTS_REMOVE_SONG_ENDPOINT:" << url;
    return url;
}

QString AppConfig::getPlaylistsDeleteEndpoint(int playlistId) const
{
    QString endpoint = envVariables.value("PLAYLISTS_DELETE_ENDPOINT", getBaseUrl() + "/api/playlists");
    QString url = endpoint + "/" + QString::number(playlistId);
    qDebug() << "AppConfig: Generated PLAYLISTS_DELETE_ENDPOINT:" << url;
    return url;
}