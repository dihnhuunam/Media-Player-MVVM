#include "PlaylistModel.hpp"
#include <QUrl>
#include <QNetworkRequest>
#include <QDebug>

PlaylistModel::PlaylistModel(QObject *parent)
    : QAbstractListModel(parent),
      m_networkManager(this),
      m_settings(new QSettings("MediaPlayer", "Auth", this))
{
    connect(&m_networkManager, &QNetworkAccessManager::finished,
            this, &PlaylistModel::handleNetworkReply);
}

int PlaylistModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_playlists.count();
}

QVariant PlaylistModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_playlists.count())
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
    QString token = m_settings->value("jwt_token", "").toString();
    return !token.isEmpty();
}

void PlaylistModel::loadUserPlaylists()
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to load playlists");
        qDebug() << "PlaylistModel: User not authenticated";
        return;
    }

    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(m_baseUrl + "/playlists");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", ("Bearer " + m_settings->value("jwt_token", "").toString()).toUtf8());

    m_networkManager.get(request);
    qDebug() << "PlaylistModel: Loading user playlists";
}

void PlaylistModel::createPlaylist(const QString &name, const QString &description)
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to create a playlist");
        qDebug() << "PlaylistModel: User not authenticated";
        return;
    }

    QJsonObject jsonObject;
    jsonObject["name"] = name;
    jsonObject["description"] = description.isEmpty() ? QJsonValue() : description;

    QNetworkRequest request(QUrl(m_baseUrl + "/playlists"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", ("Bearer " + m_settings->value("jwt_token", "").toString()).toUtf8());

    QByteArray jsonData = QJsonDocument(jsonObject).toJson();
    m_networkManager.post(request, jsonData);
    qDebug() << "PlaylistModel: Creating playlist:" << name;
}

void PlaylistModel::updatePlaylist(int playlistId, const QString &name, const QString &description)
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to update a playlist");
        qDebug() << "PlaylistModel: User not authenticated";
        return;
    }

    QJsonObject jsonObject;
    jsonObject["name"] = name;
    jsonObject["description"] = description.isEmpty() ? QJsonValue() : description;

    QNetworkRequest request(QUrl(m_baseUrl + "/playlists/" + QString::number(playlistId)));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", ("Bearer " + m_settings->value("jwt_token", "").toString()).toUtf8());

    QByteArray jsonData = QJsonDocument(jsonObject).toJson();
    m_networkManager.sendCustomRequest(request, "PUT", jsonData);
    qDebug() << "PlaylistModel: Updating playlist:" << playlistId;
}

void PlaylistModel::deletePlaylist(int playlistId)
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to delete a playlist");
        qDebug() << "PlaylistModel: User not authenticated";
        return;
    }

    QNetworkRequest request(QUrl(m_baseUrl + "/playlists/" + QString::number(playlistId)));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", ("Bearer " + m_settings->value("jwt_token", "").toString()).toUtf8());

    m_networkManager.deleteResource(request);
    qDebug() << "PlaylistModel: Deleting playlist:" << playlistId;
}

void PlaylistModel::addSongToPlaylist(int playlistId, int songId)
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to add a song to playlist");
        qDebug() << "PlaylistModel: User not authenticated";
        return;
    }

    QJsonObject jsonObject;
    jsonObject["playlistId"] = playlistId;
    jsonObject["songId"] = songId;

    QNetworkRequest request(QUrl(m_baseUrl + "/playlists/songs"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", ("Bearer " + m_settings->value("jwt_token", "").toString()).toUtf8());

    QByteArray jsonData = QJsonDocument(jsonObject).toJson();
    m_networkManager.post(request, jsonData);
    qDebug() << "PlaylistModel: Adding song" << songId << "to playlist" << playlistId;
}

void PlaylistModel::removeSongFromPlaylist(int playlistId, int songId)
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to remove a song from playlist");
        qDebug() << "PlaylistModel: User not authenticated";
        return;
    }

    QNetworkRequest request(QUrl(m_baseUrl + "/playlists/" + QString::number(playlistId) + "/songs/" + QString::number(songId)));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", ("Bearer " + m_settings->value("jwt_token", "").toString()).toUtf8());

    m_networkManager.deleteResource(request);
    qDebug() << "PlaylistModel: Removing song" << songId << "from playlist" << playlistId;
}

void PlaylistModel::loadSongsInPlaylist(int playlistId)
{
    if (!isAuthenticated())
    {
        emit errorOccurred("Please login to load songs in playlist");
        qDebug() << "PlaylistModel: User not authenticated";
        return;
    }

    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(m_baseUrl + "/playlists/" + QString::number(playlistId) + "/songs");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", ("Bearer " + m_settings->value("jwt_token", "").toString()).toUtf8());

    m_networkManager.get(request);
    qDebug() << "PlaylistModel: Loading songs for playlist" << playlistId;
}

void PlaylistModel::handleNetworkReply(QNetworkReply *reply)
{
    m_isLoading = false;
    emit isLoadingChanged();

    if (reply->error() != QNetworkReply::NoError)
    {
        emit errorOccurred(reply->errorString());
        reply->deleteLater();
        return;
    }

    QByteArray data = reply->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(data);
    QString endpoint = reply->url().path();

    if (reply->operation() == QNetworkAccessManager::GetOperation)
    {
        if (endpoint.contains("/playlists/") && endpoint.endsWith("/songs"))
        {
            int playlistId = endpoint.split("/")[2].toInt();
            if (jsonDoc.isArray())
            {
                QJsonArray songsArray = jsonDoc.array();
                QList<SongData> songs;
                for (const QJsonValue &songValue : songsArray)
                {
                    QJsonObject songObj = songValue.toObject();
                    SongData song;
                    song.id = songObj["id"].toInt();
                    song.title = songObj["title"].toString();
                    song.artists = songObj["artists"].toVariant().toStringList();
                    song.filePath = songObj["file_path"].toString();
                    song.genres = songObj["genres"].toVariant().toStringList();
                    songs.append(song);
                }
                emit songsLoaded(playlistId, songs, "Songs loaded successfully");
            }
            else
            {
                emit errorOccurred("Invalid response format for songs");
            }
        }
        else if (endpoint.contains("/playlists"))
        {
            beginResetModel();
            m_playlists.clear();
            QJsonArray playlists = jsonDoc.array();

            for (const QJsonValue &value : playlists)
            {
                QJsonObject obj = value.toObject();
                PlaylistData playlist;
                playlist.id = obj["id"].toInt();
                playlist.name = obj["name"].toString();
                playlist.description = obj["description"].toString();
                playlist.userId = obj["userId"].toInt();
                playlist.imageUrl = ""; // Không có trường imageUrl từ API hiện tại

                QJsonArray songsArray = obj["songs"].toArray();
                for (const QJsonValue &songValue : songsArray)
                {
                    QJsonObject songObj = songValue.toObject();
                    SongData song;
                    song.id = songObj["id"].toInt();
                    song.title = songObj["title"].toString();
                    song.artists = songObj["artists"].toVariant().toStringList();
                    song.filePath = songObj["file_path"].toString();
                    song.genres = songObj["genres"].toVariant().toStringList();
                    playlist.songs.append(song);
                }

                m_playlists.append(playlist);
            }
            endResetModel();
            emit playlistsChanged();
        }
    }
    else if (reply->operation() == QNetworkAccessManager::PostOperation)
    {
        if (endpoint.contains("/playlists/songs"))
        {
            int playlistId = jsonDoc.object()["playlistId"].toInt();
            emit songAdded(playlistId);
        }
        else if (endpoint.contains("/playlists"))
        {
            QJsonObject obj = jsonDoc.object();
            emit playlistCreated(obj["playlistId"].toInt());
        }
    }
    else if (reply->operation() == QNetworkAccessManager::CustomOperation && reply->request().attribute(QNetworkRequest::CustomVerbAttribute).toString() == "PUT")
    {
        int playlistId = endpoint.split("/")[2].toInt();
        emit playlistUpdated(playlistId);
    }
    else if (reply->operation() == QNetworkAccessManager::DeleteOperation)
    {
        if (endpoint.contains("/songs"))
        {
            int playlistId = endpoint.split("/")[2].toInt();
            emit songRemoved(playlistId);
        }
        else
        {
            int playlistId = endpoint.split("/")[2].toInt();
            emit playlistDeleted(playlistId);
        }
    }

    reply->deleteLater();
}