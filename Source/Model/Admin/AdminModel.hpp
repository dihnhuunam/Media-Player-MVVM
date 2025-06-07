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

public slots:
    void uploadSong(const QString &title, const QString &genres, const QString &artists, const QString &filePath);
    void updateSong(int songId, const QString &title, const QString &genres, const QString &artists);
    void deleteSong(int songId);
    void fetchSongById(int songId);
    void fetchAllUsers();
    void searchUsersByName(const QString &name); 

signals:
    void uploadFinished(bool success, const QString &message, int songId = -1);
    void updateFinished(bool success, const QString &message);
    void deleteFinished(bool success, const QString &message);
    void songFetched(bool success, const QString &title, const QString &genres, const QString &artists, const QString &errorMessage = "");
    void usersFetched(bool success, const QVariantList &users, const QString &errorMessage = "");

private:
    QNetworkAccessManager *m_networkManager;
};

#endif // ADMINMODEL_HPP