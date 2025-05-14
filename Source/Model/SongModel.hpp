#ifndef SONGMODEL_H
#define SONGMODEL_H

#include <QAbstractListModel>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

struct SongData
{
    int id;
    QString title;
    QStringList artists; // Đổi từ artist (QString) thành artists (QStringList)
    QString filePath;
    QStringList genres;
};

class SongModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY songsChanged)

public:
    explicit SongModel(QObject *parent = nullptr);

    enum SongRoles
    {
        IdRole = Qt::UserRole + 1,
        TitleRole,
        ArtistsRole, // Đổi từ ArtistRole thành ArtistsRole
        FilePathRole,
        GenresRole
    };

    // QAbstractListModel overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Properties
    QString query() const { return m_query; }
    void setQuery(const QString &query);

    // Public methods
    Q_INVOKABLE void searchSongs(const QString &query);
    Q_INVOKABLE QString getStreamUrl(int songId) const;

signals:
    void queryChanged();
    void songsChanged();
    void errorOccurred(const QString &error);

private slots:
    void handleSearchReply(QNetworkReply *reply);

private:
    QString m_query;
    QList<SongData> m_songs;
    QNetworkAccessManager m_networkManager;
    QString m_baseUrl = "http://localhost:3000";
};

#endif // SONGMODEL_H