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
    QStringList artists;
    QString filePath;
    QStringList genres;
};

class SongModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY songsChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

public:
    explicit SongModel(QObject *parent = nullptr);

    enum SongRoles
    {
        IdRole = Qt::UserRole + 1,
        TitleRole,
        ArtistsRole,
        FilePathRole,
        GenresRole
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString query() const { return m_query; }
    void setQuery(const QString &query);

    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void searchSongs(const QString &query);
    Q_INVOKABLE void fetchAllSongs();
    Q_INVOKABLE QString getStreamUrl(int songId) const;

signals:
    void queryChanged();
    void songsChanged();
    void errorOccurred(const QString &error);
    void isLoadingChanged();

private slots:
    void onSearchReply();
    void onFetchAllSongsReply();

private:
    QString m_query;
    QList<QMap<int, QVariant>> m_songs;
    QNetworkAccessManager *m_networkManager;
    bool m_isLoading = false;
};

#endif // SONGMODEL_H