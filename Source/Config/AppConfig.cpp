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
            continue; // Bỏ qua dòng trống hoặc comment

        QStringList parts = line.split("=");
        if (parts.size() < 2)
            continue;

        QString key = parts[0].trimmed();
        QString value = parts.mid(1).join("=").trimmed();

        // Thay thế các biến trong giá trị (ví dụ: ${BASE_URL})
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

QString AppConfig::getSongsSearchEndpoint() const
{
    return envVariables.value("SONGS_SEARCH_ENDPOINT", getBaseUrl() + "/api/songs/search");
}

QString AppConfig::getSongsStreamEndpoint(int songId) const
{
    QString endpoint = envVariables.value("SONGS_STREAM_ENDPOINT", getBaseUrl() + "/api/songs/stream");
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