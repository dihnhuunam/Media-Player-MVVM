#include "SongModel.hpp"
#include <QUrl>
#include <QUrlQuery>
#include <QDebug>

SongModel::SongModel(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(&m_networkManager, &QNetworkAccessManager::finished,
            this, &SongModel::handleSearchReply);
}

int SongModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_songs.count();
}

QVariant SongModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_songs.count())
        return QVariant();

    const SongData &song = m_songs[index.row()];
    switch (role)
    {
    case Id_ROLE:
        return song.id;
    case TitleRole:
        return song.title;
    case ArtistsRole:
        return song.artists;
    case FilePathRole:
        return song.filePath;
    case GenresRole:
        return song.genres;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> SongModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Id_ROLE] = "id";
    roles[TitleRole] = "title";
    roles[ArtistsRole] = "artists";
    roles[FilePathRole] = "filePath";
    roles[GenresRole] = "genres";
    return roles;
}

void SongModel::setQuery(const QString &query)
{
    if (m_query != query)
    {
        m_query = query;
        emit queryChanged();
        searchSongs(query);
    }
}

void SongModel::searchSongs(const QString &query)
{
    if (query.isEmpty())
    {
        beginResetModel();
        m_songs.clear();
        m_isLoading = false;
        endResetModel();
        emit songsChanged();
        emit isLoadingChanged();
        return;
    }

    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(m_baseUrl + "/api/songs/search");
    QUrlQuery urlQuery;
    urlQuery.addQueryItem("q", query);
    url.setQuery(urlQuery);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    m_networkManager.get(request);
    qDebug() << "SongModel: Searching songs with query:" << query;
}

QString SongModel::getStreamUrl(int songId) const
{
    return m_baseUrl + "/api/songs/stream/" + QString::number(songId);
}

void SongModel::handleSearchReply(QNetworkReply *reply)
{
    m_isLoading = false;
    emit isLoadingChanged();

    if (reply->error() != QNetworkReply::NoError)
    {
        emit errorOccurred(reply->errorString());
        qDebug() << "SongModel: Network error:" << reply->errorString();
        reply->deleteLater();
        return;
    }

    QByteArray data = reply->readAll();
    qDebug() << "SongModel: Raw API response:" << data;

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isNull() || !doc.isArray())
    {
        emit errorOccurred("Invalid JSON response");
        qDebug() << "SongModel: Invalid JSON response";
        reply->deleteLater();
        return;
    }

    beginResetModel();
    m_songs.clear();

    QJsonArray songsArray = doc.array();
    for (const QJsonValue &value : songsArray)
    {
        QJsonObject obj = value.toObject();
        SongData song;
        song.id = obj["id"].toInt();
        song.title = obj["title"].toString();
        song.filePath = obj["file_path"].toString();

        QJsonArray artistsArray = obj["artists"].toArray();
        for (const QJsonValue &artist : artistsArray)
        {
            song.artists.append(artist.toString());
        }

        QJsonArray genresArray = obj["genres"].toArray();
        for (const QJsonValue &genre : genresArray)
        {
            song.genres.append(genre.toString());
        }

        m_songs.append(song);
    }

    endResetModel();
    emit songsChanged();
    qDebug() << "SongModel: Loaded" << m_songs.count() << "songs";

    reply->deleteLater();
}