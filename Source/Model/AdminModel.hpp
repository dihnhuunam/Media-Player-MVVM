#ifndef ADMINMODEL_HPP
#define ADMINMODEL_HPP

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QFile>

class AdminModel : public QObject
{
    Q_OBJECT
public:
    explicit AdminModel(QObject *parent = nullptr);

    void uploadSong(const QString &title, const QString &genres, const QString &artists, const QString &filePath);

signals:
    void uploadFinished(bool success, const QString &message, int songId = -1);

private:
    QNetworkAccessManager *m_networkManager;
};

#endif // ADMINMODEL_HPP