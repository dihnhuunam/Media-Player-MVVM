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
    if (query.trimmed().isEmpty())
    {
        emit errorOccurred("Search query cannot be empty");
        return;
    }
    m_query = query;
    emit queryChanged();
    searchSongs(query);
}

void SongModel::searchSongs(const QString &query)
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please log in to search for songs");
        return;
    }

    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(AppConfig::instance().getSongsSearchEndpoint());
    QUrlQuery queryParams;
    queryParams.addQueryItem("q", query);
    url.setQuery(queryParams);

    QNetworkRequest request(url);
    QString token = AppState::instance()->getToken();
    if (!token.isEmpty())
        request.setRawHeader("Authorization", "Bearer " + token.toUtf8());

    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, &SongModel::onSearchReply);
}

void SongModel::fetchAllSongs()
{
    if (!AppState::instance()->isAuthenticated())
    {
        emit errorOccurred("Please log in to fetch all songs");
        return;
    }

    m_isLoading = true;
    emit isLoadingChanged();

    QUrl url(AppConfig::instance().getSongsEndpoint());
    QNetworkRequest request(url);
    QString token = AppState::instance()->getToken();
    if (!token.isEmpty())
        request.setRawHeader("Authorization", "Bearer " + token.toUtf8());

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
    if (!reply)
        return;

    m_isLoading = false;
    emit isLoadingChanged();

    int httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QString message;

    if (reply->error() == QNetworkReply::NoError && httpStatus >= 200 && httpStatus < 300)
    {
        QByteArray responseData = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(responseData);
        if (!doc.isArray())
        {
            emit errorOccurred("Invalid response format from server");
            reply->deleteLater();
            return;
        }

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
                    QString artistName = artist.toString().trimmed();
                    if (!artistName.isEmpty())
                        artists.append(QVariant(artistName));
                }
            }
            song[ArtistsRole] = artists;

            song[FilePathRole] = obj["file_path"].toString();

            QVariantList genres;
            QJsonArray genreArray = obj["genres"].toArray();
            for (const QJsonValue &genre : genreArray)
            {
                QString genreName = genre.toString().trimmed();
                if (!genreName.isEmpty())
                    genres.append(QVariant(genreName));
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
        message = m_songs.isEmpty() ? "No songs found" : "Songs loaded successfully";
    }
    else
    {
        QByteArray responseData = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(responseData);
        if (!doc.isNull() && doc.isObject())
        {
            message = doc.object()["message"].toString();
        }
        if (message.isEmpty())
            message = reply->errorString();

        switch (httpStatus)
        {
        case 400:
            message = message.isEmpty() ? "Bad request: Invalid search query" : message;
            break;
        case 401:
            message = message.isEmpty() ? "Unauthorized: Please log in" : message;
            if (httpStatus == 401)
            {
                AppState::instance()->clearUserInfo();
            }
            break;
        case 404:
            message = message.isEmpty() ? "No songs found" : message;
            break;
        case 416:
            message = message.isEmpty() ? "Requested range not satisfiable" : message;
            break;
        case 500:
            message = message.isEmpty() ? "Internal server error" : message;
            break;
        default:
            message = message.isEmpty() ? "An error occurred while searching songs" : message;
            break;
        }
        emit errorOccurred(message);
    }

    reply->deleteLater();
}

void SongModel::onFetchAllSongsReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply)
        return;

    m_isLoading = false;
    emit isLoadingChanged();

    int httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QString message;

    if (reply->error() == QNetworkReply::NoError && httpStatus >= 200 && httpStatus < 300)
    {
        QByteArray responseData = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(responseData);
        if (!doc.isArray())
        {
            emit errorOccurred("Invalid response format from server");
            reply->deleteLater();
            return;
        }

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
                    QString artistName = artist.toString().trimmed();
                    if (!artistName.isEmpty())
                        artists.append(QVariant(artistName));
                }
            }
            song[ArtistsRole] = artists;

            song[FilePathRole] = obj["file_path"].toString();

            QVariantList genres;
            QJsonArray genreArray = obj["genres"].toArray();
            for (const QJsonValue &genre : genreArray)
            {
                QString genreName = genre.toString().trimmed();
                if (!genreName.isEmpty())
                    genres.append(QVariant(genreName));
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
        message = m_songs.isEmpty() ? "No songs available" : "Songs loaded successfully";
    }
    else
    {
        QByteArray responseData = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(responseData);
        if (!doc.isNull() && doc.isObject())
        {
            message = doc.object()["message"].toString();
        }
        if (message.isEmpty())
            message = reply->errorString();

        switch (httpStatus)
        {
        case 400:
            message = message.isEmpty() ? "Bad request: Invalid request parameters" : message;
            break;
        case 401:
            message = message.isEmpty() ? "Unauthorized: Please log in" : message;
            if (httpStatus == 401)
            {
                AppState::instance()->clearUserInfo();
            }
            break;
        case 404:
            message = message.isEmpty() ? "No songs found" : message;
            break;
        case 416:
            message = message.isEmpty() ? "Requested range not satisfiable" : message;
            break;
        case 500:
            message = message.isEmpty() ? "Internal server error" : message;
            break;
        default:
            message = message.isEmpty() ? "An error occurred while fetching songs" : message;
            break;
        }
        emit errorOccurred(message);
    }

    reply->deleteLater();
}