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
    return endpoint + "/" + QString::number(userId);
}

QString AppConfig::getAuthGetUsersEndpoint() const
{
    return envVariables.value("AUTH_GET_USERS_ENDPOINT", getBaseUrl() + "/api/auth/users");
}

QString AppConfig::getAuthGetUserByIdEndpoint(int userId) const
{
    QString endpoint = envVariables.value("AUTH_GET_USER_BY_ID_ENDPOINT", getBaseUrl() + "/api/auth/users");
    return endpoint + "/" + QString::number(userId);
}

QString AppConfig::getSongsEndpoint() const
{
    return envVariables.value("SONGS_ENDPOINT", getBaseUrl() + "/api/songs");
}

QString AppConfig::getSongsSearchEndpoint() const
{
    return envVariables.value("SONGS_SEARCH_ENDPOINT", getBaseUrl() + "/api/songs/search");
}

QString AppConfig::getSongsStreamEndpoint(int songId) const
{
    QString endpoint = envVariables.value("SONGS_STREAM_ENDPOINT", getBaseUrl() + "/api/songs/stream");
    return endpoint + "/" + QString::number(songId);
}

QString AppConfig::getSongsSearchByGenresEndpoint() const
{
    return envVariables.value("SONGS_SEARCH_BY_GENRES_ENDPOINT", getBaseUrl() + "/api/songs/search-by-genres");
}

QString AppConfig::getSongsUpdateEndpoint(int songId) const
{
    QString endpoint = envVariables.value("SONGS_UPDATE_ENDPOINT", getBaseUrl() + "/api/songs");
    return endpoint + "/" + QString::number(songId);
}

QString AppConfig::getSongsDeleteEndpoint(int songId) const
{
    QString endpoint = envVariables.value("SONGS_DELETE_ENDPOINT", getBaseUrl() + "/api/songs");
    return endpoint + "/" + QString::number(songId);
}

QString AppConfig::getPlaylistsEndpoint() const
{
    return envVariables.value("PLAYLISTS_ENDPOINT", getBaseUrl() + "/api/playlists");
}

QString AppConfig::getPlaylistEndpoint(int playlistId) const
{
    return getPlaylistsEndpoint() + "/" + QString::number(playlistId);
}

QString AppConfig::getPlaylistsSongsEndpoint() const
{
    return envVariables.value("PLAYLISTS_SONGS_ENDPOINT", getBaseUrl() + "/api/playlists/songs");
}

QString AppConfig::getPlaylistSongsEndpoint(int playlistId) const
{
    return getPlaylistsEndpoint() + "/" + QString::number(playlistId) + "/songs";
}

QString AppConfig::getPlaylistSongEndpoint(int playlistId, int songId) const
{
    return getPlaylistSongsEndpoint(playlistId) + "/" + QString::number(songId);
}

QString AppConfig::getPlaylistsSearchEndpoint() const
{
    return envVariables.value("PLAYLISTS_SEARCH_ENDPOINT", getBaseUrl() + "/api/playlists/search");
}

QString AppConfig::getPlaylistSongsSearchEndpoint(int playlistId) const
{
    return envVariables.value("PLAYLISTS_SEARCH_SONGS_ENDPOINT", getBaseUrl() + "/api/playlists/" + QString::number(playlistId) + "/songs/search");
}

QString AppConfig::getPlaylistsCreateEndpoint() const
{
    return envVariables.value("PLAYLISTS_CREATE_ENDPOINT", getBaseUrl() + "/api/playlists");
}

QString AppConfig::getPlaylistsGetUserPlaylistsEndpoint() const
{
    return envVariables.value("PLAYLISTS_GET_USER_PLAYLISTS_ENDPOINT", getBaseUrl() + "/api/playlists");
}

QString AppConfig::getPlaylistsAddSongEndpoint() const
{
    return envVariables.value("PLAYLISTS_ADD_SONG_ENDPOINT", getBaseUrl() + "/api/playlists/songs");
}

QString AppConfig::getPlaylistsUpdateNameEndpoint(int playlistId) const
{
    QString endpoint = envVariables.value("PLAYLISTS_UPDATE_NAME_ENDPOINT", getBaseUrl() + "/api/playlists");
    return endpoint + "/" + QString::number(playlistId);
}

QString AppConfig::getPlaylistsRemoveSongEndpoint() const
{
    return envVariables.value("PLAYLISTS_REMOVE_SONG_ENDPOINT", getBaseUrl() + "/api/playlists/songs");
}

QString AppConfig::getPlaylistsDeleteEndpoint(int playlistId) const
{
    QString endpoint = envVariables.value("PLAYLISTS_DELETE_ENDPOINT", getBaseUrl() + "/api/playlists");
    return endpoint + "/" + QString::number(playlistId);
}