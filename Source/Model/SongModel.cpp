#include "SongModel.hpp"
#include "AppConfig.hpp"
#include <QJsonDocument>
#include <QJsonArray>
#include <QUrlQuery>

SongModel::SongModel(QObject *parent) : QAbstractListModel(parent), m_networkManager(new QNetworkAccessManager(this)) {}

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
    switch (role)
    {
    case IdRole:
        return song[IdRole];
    case TitleRole:
        return song[TitleRole];
    case ArtistsRole:
        return song[ArtistsRole];
    case FilePathRole:
        return song[FilePathRole];
    case GenresRole:
        return song[GenresRole];
    default:
        return QVariant();
    }
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
                song[TitleRole] = obj["title"].toString();
                song[ArtistsRole] = obj["artists"].toVariant().toStringList();
                song[FilePathRole] = obj["file_path"].toString();
                song[GenresRole] = obj["genres"].toVariant().toStringList();
                m_songs.append(song);
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