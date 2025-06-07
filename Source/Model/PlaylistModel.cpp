#include "PlaylistModel.hpp"
#include "AppConfig.hpp"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrlQuery>

PlaylistModel::PlaylistModel(QObject *parent)
    : QAbstractListModel(parent), m_networkManager(), m_settings(new QSettings("MediaPlayer", "Auth", this))
{
}

int PlaylistModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_playlists.count();
}

QVariant PlaylistModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_playlists.count())
    {
        return QVariant();
    }

    const PlaylistData &playlist = m_playlists[index.row()];
    switch (role)
    {
    case IdRole:
        return playlist.id;
    case NameRole:
        return playlist.name;
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

void PlaylistModel::createPlaylist(const QString &name)
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
    QJsonDocument doc(json);
    QByteArray data = doc.toJson();

    QNetworkReply *reply = m_networkManager.post(request, data);
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            { handleNetworkReply(reply); });
}

void PlaylistModel::updatePlaylist(int playlistId, const QString &name)
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

    QUrl url(AppConfig::instance().getPlaylistsRemoveSongEndpoint());
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

    QNetworkReply *reply = m_networkManager.sendCustomRequest(request, "DELETE", data);
    connect(reply, &QNetworkReply::finished, this, [this, reply, playlistId, songId]()
            { handleNetworkReply(reply, playlistId, songId); });
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
    connect(reply, &QNetworkReply::finished, this, [this, reply, playlistId]()
            { handleNetworkReply(reply, playlistId); });
}

void PlaylistModel::search(const QString &query, int limit, int offset)
{
    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(AppConfig::instance().getPlaylistsSearchEndpoint());
    QUrlQuery queryParams;
    queryParams.addQueryItem("q", query);
    queryParams.addQueryItem("limit", QString::number(limit));
    queryParams.addQueryItem("offset", QString::number(offset));
    url.setQuery(queryParams);

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

void PlaylistModel::searchSongsInPlaylist(int playlistId, const QString &query, int limit, int offset)
{
    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(AppConfig::instance().getPlaylistSongsSearchEndpoint(playlistId));
    QUrlQuery queryParams;
    queryParams.addQueryItem("q", query);
    queryParams.addQueryItem("limit", QString::number(limit));
    queryParams.addQueryItem("offset", QString::number(offset));
    url.setQuery(queryParams);

    QNetworkRequest request(url);
    QString token = m_settings->value("jwt_token").toString();
    if (!token.isEmpty())
    {
        request.setRawHeader("Authorization", "Bearer " + token.toUtf8());
    }

    QNetworkReply *reply = m_networkManager.get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, playlistId]()
            { handleNetworkReply(reply, playlistId); });
}

void PlaylistModel::handleNetworkReply(QNetworkReply *reply, int playlistId, int songId)
{
    if (!reply)
        return;

    QString endpoint = reply->url().path();
    QString message;
    bool success = (reply->error() == QNetworkReply::NoError);

    if (success)
    {
        QByteArray responseData = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(responseData);

        if (doc.isArray())
        {
            if (endpoint.contains("/playlists") && !endpoint.contains("/songs"))
            {
                // Handle playlists list (including search)
                QJsonArray jsonArray = doc.array();
                QList<PlaylistData> playlists;
                for (const QJsonValue &value : jsonArray)
                {
                    QJsonObject obj = value.toObject();
                    PlaylistData playlist;
                    playlist.id = obj["id"].toInt();
                    playlist.name = obj["name"].toString();
                    playlist.songs.clear();
                    playlist.imageUrl = obj["imageUrl"].toString("");
                    playlist.userId = obj["userId"].toInt(0);
                    playlists.append(playlist);
                }
                if (endpoint.contains("/search"))
                {
                    // Playlist search results
                    message = playlists.isEmpty() ? "No playlists found" : "Playlists loaded successfully";
                    emit searchResultsLoaded(playlists, message);
                }
                else
                {
                    // Regular playlist list
                    beginResetModel();
                    m_playlists = playlists;
                    endResetModel();
                    message = playlists.isEmpty() ? "No playlists available" : "Playlists loaded successfully";
                    emit playlistsChanged();
                }
            }
            else if (endpoint.contains("/songs"))
            {
                // Handle songs in playlist or song search results
                QJsonArray jsonArray = doc.array();
                QList<SongData> songs;
                for (const QJsonValue &value : jsonArray)
                {
                    QJsonObject obj = value.toObject();
                    SongData song;
                    song.id = obj["id"].toInt();
                    song.title = obj["title"].toString().trimmed();
                    if (song.title.isEmpty())
                        song.title = "Unknown Title";

                    // Handle artists safely
                    QJsonArray artistsArray = obj["artists"].toArray();
                    QStringList artists;
                    if (artistsArray.isEmpty() || !obj.contains("artists"))
                        artists.append("Unknown Artist");
                    else
                        for (const QJsonValue &artist : artistsArray)
                            if (!artist.toString().trimmed().isEmpty())
                                artists.append(artist.toString().trimmed());
                    if (artists.isEmpty())
                        artists.append("Unknown Artist");
                    song.artists = artists;

                    song.filePath = obj["file_path"].toString();
                    if (song.filePath.isEmpty())
                        song.filePath = "";

                    // Handle genres safely
                    QJsonArray genresArray = obj["genres"].toArray();
                    QStringList genres;
                    if (!genresArray.isEmpty())
                        for (const QJsonValue &genre : genresArray)
                            if (!genre.toString().trimmed().isEmpty())
                                genres.append(genre.toString().trimmed());
                    song.genres = genres;

                    songs.append(song);
                }
                // Use provided playlistId instead of extracting from URL
                int effectivePlaylistId = playlistId;
                if (endpoint.contains("/search"))
                {
                    // Song search results in playlist
                    message = songs.isEmpty() ? "No songs found" : "Song search results loaded successfully";
                    emit songSearchResultsLoaded(effectivePlaylistId, songs, message);
                }
                else
                {
                    // Regular songs in playlist
                    message = songs.isEmpty() ? "No songs in this playlist" : "Songs loaded successfully";
                    emit songsLoaded(effectivePlaylistId, songs, message);
                }
            }
        }
        else if (doc.isObject())
        {
            QJsonObject jsonObj = doc.object();
            message = jsonObj["message"].toString();
            if (endpoint.endsWith("/playlists") && reply->operation() == QNetworkAccessManager::PostOperation)
            {
                int playlistId = jsonObj["playlistId"].toInt();
                emit playlistCreated(playlistId);
            }
            else if (endpoint.contains("/playlists/") && reply->operation() == QNetworkAccessManager::PutOperation)
            {
                int playlistId = endpoint.split('/').last().toInt();
                emit playlistUpdated(playlistId);
            }
            else if (endpoint.contains("/playlists/") && reply->operation() == QNetworkAccessManager::DeleteOperation)
            {
                int playlistId = endpoint.split('/').last().toInt();
                emit playlistDeleted(playlistId);
            }
            else if (endpoint.endsWith("/playlists/songs") && reply->operation() == QNetworkAccessManager::PostOperation)
            {
                int playlistId = jsonObj["playlistId"].toInt();
                emit songAdded(playlistId);
            }
            else if (endpoint.endsWith("/playlists/songs") && reply->operation() == QNetworkAccessManager::CustomOperation)
            {
                if (message == "Song removed from playlist successfully")
                {
                    emit songRemoved(playlistId, songId);
                }
                else
                {
                    success = false;
                    message = "Unexpected response: " + message;
                }
            }
        }
        else
        {
            success = false;
            message = "Invalid response format from server";
        }
    }
    else
    {
        // Handle specific HTTP errors
        int httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        if (doc.isObject())
            message = doc.object()["message"].toString();
        else
            message = reply->errorString();

        if (httpStatus == 400)
            message = message.isEmpty() ? "Bad request: Invalid parameters" : message;
        else if (httpStatus == 401)
            message = message.isEmpty() ? "Unauthorized: Invalid or expired token" : message;
        else if (httpStatus == 403)
            message = message.isEmpty() ? "Forbidden: Insufficient permissions" : message;
        else if (httpStatus == 404)
            message = message.isEmpty() ? "Not found: Resource does not exist" : message;
        else if (httpStatus == 409)
            message = message.isEmpty() ? "Song is already in the playlist" : message;
        else
            message = message.isEmpty() ? "An error occurred" : message;

        emit errorOccurred(message);
    }

    if (!success)
        emit errorOccurred(message);

    m_isLoading = false;
    emit isLoadingChanged();
    reply->deleteLater();
}