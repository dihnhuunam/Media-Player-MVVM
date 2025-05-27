#include "AdminModel.hpp"
#include "AppState.hpp"
#include "AppConfig.hpp"
#include <QNetworkRequest>
#include <QHttpMultiPart>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QDebug>

AdminModel::AdminModel(QObject *parent)
    : QObject(parent), m_networkManager(new QNetworkAccessManager(this))
{
}

void AdminModel::uploadSong(const QString &title, const QString &genres, const QString &artists, const QString &filePath)
{
    // Use AppConfig to get the songs endpoint
    QUrl url(AppConfig::instance().getSongsEndpoint());
    QNetworkRequest request(url);

    // Authentication token
    QString token = AppState::instance()->getToken();
    if (token.isEmpty())
    {
        emit uploadFinished(false, "No authentication token available");
        return;
    }
    request.setRawHeader("Authorization", QString("Bearer %1").arg(token).toUtf8());

    // Validate inputs
    if (title.isEmpty() || genres.isEmpty() || artists.isEmpty() || filePath.isEmpty())
    {
        emit uploadFinished(false, "All fields (title, genres, artists, file) are required");
        return;
    }

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    // Add title
    QHttpPart titlePart;
    titlePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"title\""));
    titlePart.setBody(title.toUtf8());
    multiPart->append(titlePart);

    // Add genres
    QHttpPart genresPart;
    genresPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"genres\""));
    genresPart.setBody(genres.toUtf8());
    multiPart->append(genresPart);

    // Add artists
    QHttpPart artistsPart;
    artistsPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"artists\""));
    artistsPart.setBody(artists.toUtf8());
    multiPart->append(artistsPart);

    // Add file
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

    // Determine MIME type
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
    file->setParent(multiPart); // Ensure file is deleted with multiPart
    multiPart->append(filePart);

    // Log request headers for debugging
    QNetworkReply *reply = m_networkManager->post(request, multiPart);
    multiPart->setParent(reply); // Ensure multiPart is deleted with reply

    // Log headers
    qDebug() << "AdminModel: Sending request to" << url.toString();
    qDebug() << "AdminModel: Headers:";
    for (const auto &header : request.rawHeaderList())
    {
        qDebug() << header << ":" << request.rawHeader(header);
    }

    connect(reply, &QNetworkReply::finished, this, [=]()
            {
        QString responseData = QString::fromUtf8(reply->readAll());
        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "AdminModel: HTTP Status:" << statusCode << "Response:" << responseData;

        if (reply->error() == QNetworkReply::NoError && statusCode == 201) {
            QJsonDocument doc = QJsonDocument::fromJson(responseData.toUtf8());
            if (!doc.isNull() && doc.isObject()) {
                QJsonObject obj = doc.object();
                QString message = obj.value("message").toString("Song added successfully");
                int songId = obj.value("songId").toInt(-1);
                emit uploadFinished(true, message, songId);
            } else {
                emit uploadFinished(false, "Invalid response format from server: " + responseData);
            }
        } else {
            emit uploadFinished(false, QString("Error %1: %2 - Response: %3").arg(statusCode).arg(reply->errorString(), responseData));
        }
        reply->deleteLater(); });
}