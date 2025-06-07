#include "SongModel.hpp"
#include "AppConfig.hpp"
#include <QJsonDocument>
#include <QJsonArray>
#include <QUrlQuery>
#include <QDebug>

SongModel::SongModel(QObject *parent)
    : QAbstractListModel(parent), m_networkManager(new QNetworkAccessManager(this))
{
}

int SongModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_songs.count();
}

QVariant SongModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_songs.count())
        return QVariant();
    const QMap<int, QVariant> &song = m_songs[index.row()];
    return song.value(role);
}

QHash<int, QByteArray> SongModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[TitleRole] = "title";
    roles[ArtistsRole] = "artists";
    roles[FilePathRole] = "filePath";
    roles[GenresRole] = "genres";
    return roles;
}

void SongModel::setQuery(const QString &query)
{
    if (m_query == query)
        return;
    m_query = query;
    emit queryChanged();
    searchSongs(query);
}

void SongModel::searchSongs(const QString &query)
{
    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(AppConfig::instance().getSongsSearchEndpoint());
    QUrlQuery queryParams;
    queryParams.addQueryItem("q", query);
    url.setQuery(queryParams);

    QNetworkRequest request(url);
    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, &SongModel::onSearchReply);
}

void SongModel::fetchAllSongs()
{
    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(AppConfig::instance().getSongsEndpoint());
    QNetworkRequest request(url);
    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, &SongModel::onFetchAllSongsReply);
}

QString SongModel::getStreamUrl(int songId) const
{
    return AppConfig::instance().getSongsStreamEndpoint(songId);
}

void SongModel::onSearchReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (reply)
    {
        if (reply->error() == QNetworkReply::NoError)
        {
            QByteArray responseData = reply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(responseData);
            QJsonArray jsonArray = doc.array();
            beginResetModel();
            m_songs.clear();
            for (const QJsonValue &value : jsonArray)
            {
                QJsonObject obj = value.toObject();
                QMap<int, QVariant> song;
                song[IdRole] = obj["id"].toInt();
                QString title = obj["title"].toString().trimmed();
                song[TitleRole] = title.isEmpty() ? "Unknown Title" : title;

                QVariantList artists;
                QJsonArray artistArray = obj["artists"].toArray();
                if (artistArray.isEmpty())
                {
                    artists.append(QVariant("Unknown Artist"));
                }
                else
                {
                    for (const QJsonValue &artist : artistArray)
                    {
                        artists.append(QVariant(artist.toString()));
                    }
                }
                song[ArtistsRole] = artists;

                song[FilePathRole] = obj["file_path"].toString();

                QVariantList genres;
                QJsonArray genreArray = obj["genres"].toArray();
                for (const QJsonValue &genre : genreArray)
                {
                    genres.append(QVariant(genre.toString()));
                }
                song[GenresRole] = genres;

                m_songs.append(song);
                qDebug() << "SongModel::onSearchReply: Parsed song - id:" << song[IdRole]
                         << "title:" << song[TitleRole]
                         << "artists:" << song[ArtistsRole]
                         << "filePath:" << song[FilePathRole]
                         << "genres:" << song[GenresRole];
            }
            endResetModel();
            emit songsChanged();
        }
        else
        {
            emit errorOccurred(reply->errorString());
        }
        m_isLoading = false;
        emit isLoadingChanged();
        reply->deleteLater();
    }
}

void SongModel::onFetchAllSongsReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (reply)
    {
        if (reply->error() == QNetworkReply::NoError)
        {
            QByteArray responseData = reply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(responseData);
            QJsonArray jsonArray = doc.array();
            beginResetModel();
            m_songs.clear();
            for (const QJsonValue &value : jsonArray)
            {
                QJsonObject obj = value.toObject();
                QMap<int, QVariant> song;
                song[IdRole] = obj["id"].toInt();
                QString title = obj["title"].toString().trimmed();
                song[TitleRole] = title.isEmpty() ? "Unknown Title" : title;

                QVariantList artists;
                QJsonArray artistArray = obj["artists"].toArray();
                if (artistArray.isEmpty())
                {
                    artists.append(QVariant("Unknown Artist"));
                }
                else
                {
                    for (const QJsonValue &artist : artistArray)
                    {
                        artists.append(QVariant(artist.toString()));
                    }
                }
                song[ArtistsRole] = artists;

                song[FilePathRole] = obj["file_path"].toString();

                QVariantList genres;
                QJsonArray genreArray = obj["genres"].toArray();
                for (const QJsonValue &genre : genreArray)
                {
                    genres.append(QVariant(genre.toString()));
                }
                song[GenresRole] = genres;

                m_songs.append(song);
                qDebug() << "SongModel::onFetchAllSongsReply: Parsed song - id:" << song[IdRole]
                         << "title:" << song[TitleRole]
                         << "artists:" << song[ArtistsRole]
                         << "filePath:" << song[FilePathRole]
                         << "genres:" << song[GenresRole];
            }
            endResetModel();
            emit songsChanged();
        }
        else
        {
            emit errorOccurred(reply->errorString());
        }
        m_isLoading = false;
        emit isLoadingChanged();
        reply->deleteLater();
    }
}