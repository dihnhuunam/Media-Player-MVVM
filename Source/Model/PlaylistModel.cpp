#include "PlaylistModel.hpp"
#include "AppConfig.hpp"
#include "AppState.hpp"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrlQuery>

PlaylistModel::PlaylistModel(QObject *parent) : QAbstractListModel(parent), m_networkManager(), m_settings(new QSettings("MediaPlayer", "Auth", this)) {}

int PlaylistModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_playlists.count();
}

QVariant PlaylistModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_playlists.count())
        return QVariant();
    const PlaylistData &playlist = m_playlists[index.row()];
    switch (role)
    {
    case IdRole:
        return playlist.id;
    case NameRole:
        return playlist.name;
    case DescriptionRole:
        return playlist.description;
    case SongsRole:
        return QVariant::fromValue(playlist.songs);
    case ImageUrlRole:
        return playlist.imageUrl;
    case UserIdRole:
        return playlist.userId;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> PlaylistModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[NameRole] = "name";
    roles[DescriptionRole] = "description";
    roles[SongsRole] = "songs";
    roles[ImageUrlRole] = "imageUrl";
    roles[UserIdRole] = "userId";
    return roles;
}

bool PlaylistModel::isAuthenticated() const
{
    return !m_settings->value("jwt_token").toString().isEmpty();
}

void PlaylistModel::loadUserPlaylists()
{
    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(AppConfig::instance().getPlaylistsEndpoint());
    QNetworkRequest request(url);
    QString token = m_settings->value("jwt_token").toString();
    if (!token.isEmpty())
    {
        request.setRawHeader("Authorization", "Bearer " + token.toUtf8());
    }
    QNetworkReply *reply = m_networkManager.get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            { handleNetworkReply(reply); });
}

void PlaylistModel::createPlaylist(const QString &name, const QString &description)
{
    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(AppConfig::instance().getPlaylistsEndpoint());
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QString token = m_settings->value("jwt_token").toString();
    if (!token.isEmpty())
    {
        request.setRawHeader("Authorization", "Bearer " + token.toUtf8());
    }

    QJsonObject json;
    json["name"] = name;
    json["description"] = description;
    QJsonDocument doc(json);
    QByteArray data = doc.toJson();

    QNetworkReply *reply = m_networkManager.post(request, data);
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            { handleNetworkReply(reply); });
}

void PlaylistModel::updatePlaylist(int playlistId, const QString &name, const QString &description)
{
    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(AppConfig::instance().getPlaylistEndpoint(playlistId));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QString token = m_settings->value("jwt_token").toString();
    if (!token.isEmpty())
    {
        request.setRawHeader("Authorization", "Bearer " + token.toUtf8());
    }

    QJsonObject json;
    json["name"] = name;
    json["description"] = description;
    QJsonDocument doc(json);
    QByteArray data = doc.toJson();

    QNetworkReply *reply = m_networkManager.put(request, data);
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            { handleNetworkReply(reply); });
}

void PlaylistModel::deletePlaylist(int playlistId)
{
    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(AppConfig::instance().getPlaylistEndpoint(playlistId));
    QNetworkRequest request(url);
    QString token = m_settings->value("jwt_token").toString();
    if (!token.isEmpty())
    {
        request.setRawHeader("Authorization", "Bearer " + token.toUtf8());
    }

    QNetworkReply *reply = m_networkManager.deleteResource(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            { handleNetworkReply(reply); });
}

void PlaylistModel::addSongToPlaylist(int playlistId, int songId)
{
    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(AppConfig::instance().getPlaylistsSongsEndpoint());
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QString token = m_settings->value("jwt_token").toString();
    if (!token.isEmpty())
    {
        request.setRawHeader("Authorization", "Bearer " + token.toUtf8());
    }

    QJsonObject json;
    json["playlistId"] = playlistId;
    json["songId"] = songId;
    QJsonDocument doc(json);
    QByteArray data = doc.toJson();

    QNetworkReply *reply = m_networkManager.post(request, data);
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            { handleNetworkReply(reply); });
}

void PlaylistModel::removeSongFromPlaylist(int playlistId, int songId)
{
    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(AppConfig::instance().getPlaylistSongEndpoint(playlistId, songId));
    QNetworkRequest request(url);
    QString token = m_settings->value("jwt_token").toString();
    if (!token.isEmpty())
    {
        request.setRawHeader("Authorization", "Bearer " + token.toUtf8());
    }

    QNetworkReply *reply = m_networkManager.deleteResource(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            { handleNetworkReply(reply); });
}

void PlaylistModel::loadSongsInPlaylist(int playlistId)
{
    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(AppConfig::instance().getPlaylistSongsEndpoint(playlistId));
    QNetworkRequest request(url);
    QString token = m_settings->value("jwt_token").toString();
    if (!token.isEmpty())
    {
        request.setRawHeader("Authorization", "Bearer " + token.toUtf8());
    }

    QNetworkReply *reply = m_networkManager.get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            { handleNetworkReply(reply); });
}

void PlaylistModel::handleNetworkReply(QNetworkReply *reply)
{
    if (!reply)
        return;

    if (reply->error() == QNetworkReply::NoError)
    {
        QByteArray responseData = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(responseData);
        if (doc.isArray())
        {
            QJsonArray jsonArray = doc.array();
            beginResetModel();
            m_playlists.clear();
            for (const QJsonValue &value : jsonArray)
            {
                QJsonObject obj = value.toObject();
                PlaylistData playlist;
                playlist.id = obj["id"].toInt();
                playlist.name = obj["name"].toString();
                playlist.description = obj["description"].toString();
                playlist.songs.clear(); // Không tải songs trực tiếp, cần loadSongsInPlaylist
                playlist.imageUrl = obj["imageUrl"].toString();
                playlist.userId = obj["userId"].toInt();
                m_playlists.append(playlist);
            }
            endResetModel();
            emit playlistsChanged();
        }
        else if (doc.isObject())
        {
            QJsonObject jsonObj = doc.object();
            QString endpoint = reply->url().path();
            if (endpoint.endsWith("/playlists"))
            {
                int playlistId = jsonObj["id"].toInt();
                emit playlistCreated(playlistId);
            }
            else if (endpoint.contains("/playlists/") && reply->operation() == QNetworkAccessManager::PutOperation)
            {
                int playlistId = jsonObj["id"].toInt();
                emit playlistUpdated(playlistId);
            }
            else if (endpoint.contains("/playlists/") && reply->operation() == QNetworkAccessManager::DeleteOperation)
            {
                int playlistId = jsonObj["id"].toInt();
                emit playlistDeleted(playlistId);
            }
            else if (endpoint.endsWith("/playlists/songs"))
            {
                int playlistId = jsonObj["playlistId"].toInt();
                emit songAdded(playlistId);
            }
            else if (endpoint.contains("/songs/") && reply->operation() == QNetworkAccessManager::DeleteOperation)
            {
                int playlistId = jsonObj["playlistId"].toInt();
                emit songRemoved(playlistId);
            }
            else if (endpoint.contains("/songs"))
            {
                QJsonArray jsonArray = jsonObj["songs"].toArray();
                QList<SongData> songs;
                for (const QJsonValue &value : jsonArray)
                {
                    QJsonObject obj = value.toObject();
                    SongData song;
                    song.id = obj["id"].toInt();
                    song.title = obj["title"].toString();
                    song.artists = obj["artists"].toVariant().toStringList();
                    song.filePath = obj["file_path"].toString();
                    song.genres = obj["genres"].toVariant().toStringList();
                    songs.append(song);
                }
                int playlistId = 0; // Cần lấy từ URL hoặc response
                emit songsLoaded(playlistId, songs, "Songs loaded successfully");
            }
        }
    }
    else
    {
        emit errorOccurred(reply->errorString());
    }
    m_isLoading = false;
    emit isLoadingChanged();
    reply->deleteLater();
}