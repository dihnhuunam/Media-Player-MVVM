#include "AdminModel.hpp"
#include "AppState.hpp"
#include "AppConfig.hpp"
#include <QNetworkRequest>
#include <QHttpMultiPart>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QDebug>

AdminModel::AdminModel(QObject *parent)
    : QObject(parent), m_networkManager(new QNetworkAccessManager(this))
{
}

void AdminModel::uploadSong(const QString &title, const QString &genres, const QString &artists, const QString &filePath)
{
    QUrl url(AppConfig::instance().getSongsEndpoint());
    QNetworkRequest request(url);

    QString token = AppState::instance()->getToken();
    if (token.isEmpty())
    {
        emit uploadFinished(false, "No authentication token available");
        return;
    }
    request.setRawHeader("Authorization", QString("Bearer %1").arg(token).toUtf8());

    if (title.isEmpty() || genres.isEmpty() || artists.isEmpty() || filePath.isEmpty())
    {
        emit uploadFinished(false, "All fields (title, genres, artists, file) are required");
        return;
    }

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    // Title part
    QHttpPart titlePart;
    titlePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"title\""));
    titlePart.setBody(title.toUtf8());
    multiPart->append(titlePart);

    // Genres part (split into array)
    QHttpPart genresPart;
    genresPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"genres\""));
    QJsonArray genresArray;
    for (const QString &genre : genres.split(",", Qt::SkipEmptyParts))
    {
        genresArray.append(genre.trimmed());
    }
    QJsonDocument genresDoc(genresArray);
    genresPart.setBody(genresDoc.toJson(QJsonDocument::Compact));
    multiPart->append(genresPart);

    // Artists part (split into array)
    QHttpPart artistsPart;
    artistsPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"artists\""));
    QJsonArray artistsArray;
    for (const QString &artist : artists.split(",", Qt::SkipEmptyParts))
    {
        artistsArray.append(artist.trimmed());
    }
    QJsonDocument artistsDoc(artistsArray);
    artistsPart.setBody(artistsDoc.toJson(QJsonDocument::Compact));
    multiPart->append(artistsPart);

    // File part
    QFile *file = new QFile(filePath);
    if (!file->exists())
    {
        emit uploadFinished(false, "File does not exist: " + filePath);
        delete file;
        delete multiPart;
        return;
    }
    if (!file->open(QIODevice::ReadOnly))
    {
        emit uploadFinished(false, "Failed to open file: " + filePath);
        delete file;
        delete multiPart;
        return;
    }

    QFileInfo fileInfo(filePath);
    QHttpPart filePart;
    filePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(QString("form-data; name=\"file\"; filename=\"%1\"").arg(fileInfo.fileName())));

    QMimeDatabase mimeDb;
    QMimeType mimeType = mimeDb.mimeTypeForFile(fileInfo);
    QString mimeTypeName = mimeType.name();
    if (mimeTypeName == "application/octet-stream")
    {
        QString extension = fileInfo.suffix().toLower();
        if (extension == "mp3")
        {
            mimeTypeName = "audio/mpeg";
        }
        else if (extension == "wav")
        {
            mimeTypeName = "audio/wav";
        }
        else if (extension == "m4a")
        {
            mimeTypeName = "audio/mp4";
        }
        else
        {
            emit uploadFinished(false, "Unsupported file format: " + extension);
            delete file;
            delete multiPart;
            return;
        }
    }
    filePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(mimeTypeName));
    filePart.setBodyDevice(file);
    file->setParent(multiPart);
    multiPart->append(filePart);

    qDebug() << "AdminModel: Sending upload request to" << url.toString();
    QNetworkReply *reply = m_networkManager->post(request, multiPart);
    multiPart->setParent(reply);

    connect(reply, &QNetworkReply::finished, this, [=]()
            {
        QString responseData = QString::fromUtf8(reply->readAll());
        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "AdminModel: HTTP Status:" << statusCode << "Response:" << responseData;

        if (reply->error() == QNetworkReply::NoError && statusCode == 201)
        {
            QJsonDocument doc = QJsonDocument::fromJson(responseData.toUtf8());
            if (!doc.isNull() && doc.isObject())
            {
                QJsonObject obj = doc.object();
                QString message = obj.value("message").toString("Song added successfully");
                int songId = obj.value("songId").toInt(-1);
                emit uploadFinished(true, message, songId);
            }
            else
            {
                emit uploadFinished(false, "Invalid response format from server: " + responseData);
            }
        }
        else
        {
            emit uploadFinished(false, QString("Error %1: %2 - Response: %3").arg(statusCode).arg(reply->errorString(), responseData));
        }
        reply->deleteLater(); });
}

void AdminModel::updateSong(int songId, const QString &title, const QString &genres, const QString &artists)
{
    QUrl url(AppConfig::instance().getSongsUpdateEndpoint(songId));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QString token = AppState::instance()->getToken();
    if (token.isEmpty())
    {
        emit updateFinished(false, "No authentication token available");
        return;
    }
    request.setRawHeader("Authorization", QString("Bearer %1").arg(token).toUtf8());

    if (title.isEmpty() || genres.isEmpty() || artists.isEmpty())
    {
        emit updateFinished(false, "All fields (title, genres, artists) are required");
        return;
    }

    QJsonObject json;
    json["title"] = title;

    QJsonArray genresArray;
    for (const QString &genre : genres.split(",", Qt::SkipEmptyParts))
    {
        genresArray.append(genre.trimmed());
    }
    json["genres"] = genresArray;

    QJsonArray artistsArray;
    for (const QString &artist : artists.split(",", Qt::SkipEmptyParts))
    {
        artistsArray.append(artist.trimmed());
    }
    json["artists"] = artistsArray;

    QJsonDocument doc(json);
    QNetworkReply *reply = m_networkManager->put(request, doc.toJson());

    connect(reply, &QNetworkReply::finished, this, [=]()
            {
        QString responseData = QString::fromUtf8(reply->readAll());
        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "AdminModel: Update song HTTP Status:" << statusCode << "Response:" << responseData;

        if (reply->error() == QNetworkReply::NoError && statusCode == 200)
        {
            QJsonDocument doc = QJsonDocument::fromJson(responseData.toUtf8());
            if (!doc.isNull() && doc.isObject())
            {
                QString message = doc.object().value("message").toString("Song updated successfully");
                emit updateFinished(true, message);
            }
            else
            {
                emit updateFinished(false, "Invalid response format from server: " + responseData);
            }
        }
        else
        {
            emit updateFinished(false, QString("Error %1: %2 - Response: %3").arg(statusCode).arg(reply->errorString(), responseData));
        }
        reply->deleteLater(); });
}

void AdminModel::deleteSong(int songId)
{
    QUrl url(AppConfig::instance().getSongsDeleteEndpoint(songId));
    QNetworkRequest request(url);

    QString token = AppState::instance()->getToken();
    if (token.isEmpty())
    {
        emit deleteFinished(false, "No authentication token available");
        return;
    }
    request.setRawHeader("Authorization", QString("Bearer %1").arg(token).toUtf8());

    QNetworkReply *reply = m_networkManager->deleteResource(request);

    connect(reply, &QNetworkReply::finished, this, [=]()
            {
        QString responseData = QString::fromUtf8(reply->readAll());
        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "AdminModel: Delete song HTTP Status:" << statusCode << "Response:" << responseData;

        if (reply->error() == QNetworkReply::NoError && statusCode == 200)
        {
            QJsonDocument doc = QJsonDocument::fromJson(responseData.toUtf8());
            if (!doc.isNull() && doc.isObject())
            {
                QString message = doc.object().value("message").toString("Song deleted successfully");
                emit deleteFinished(true, message);
            }
            else
            {
                emit deleteFinished(false, "Invalid response format from server: " + responseData);
            }
        }
        else
        {
            emit deleteFinished(false, QString("Error %1: %2 - Response: %3").arg(statusCode).arg(reply->errorString(), responseData));
        }
        reply->deleteLater(); });
}