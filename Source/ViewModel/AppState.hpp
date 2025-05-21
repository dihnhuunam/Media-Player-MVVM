#ifndef APPSTATE_HPP
#define APPSTATE_HPP

#include <QObject>
#include <QVariantList>

class AppState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentPlaylistName READ currentPlaylistName WRITE setCurrentPlaylistName NOTIFY currentPlaylistNameChanged)
    Q_PROPERTY(QVariantList currentMediaFiles READ currentMediaFiles WRITE setCurrentMediaFiles NOTIFY currentMediaFilesChanged)
    Q_PROPERTY(QString currentMediaTitle READ currentMediaTitle WRITE setCurrentMediaTitle NOTIFY currentMediaTitleChanged)
    Q_PROPERTY(QString currentMediaArtist READ currentMediaArtist WRITE setCurrentMediaArtist NOTIFY currentMediaArtistChanged)
    Q_PROPERTY(int currentPlaylistId READ currentPlaylistId WRITE setCurrentPlaylistId NOTIFY currentPlaylistIdChanged)

public:
    static AppState *instance();
    QString currentPlaylistName() const;
    QVariantList currentMediaFiles() const;
    QString currentMediaTitle() const;
    QString currentMediaArtist() const;
    int currentPlaylistId() const;

public slots:
    void setCurrentPlaylistName(const QString &name);
    void setCurrentMediaFiles(const QVariantList &files);
    void setCurrentMediaTitle(const QString &title);
    void setCurrentMediaArtist(const QString &artist);
    void setCurrentPlaylistId(int id);
    void setState(const QVariantMap &state);

signals:
    void currentPlaylistNameChanged();
    void currentMediaFilesChanged();
    void currentMediaTitleChanged();
    void currentMediaArtistChanged();
    void currentPlaylistIdChanged();

private:
    AppState(QObject *parent = nullptr);
    static AppState *m_instance;
    QString m_currentPlaylistName;
    QVariantList m_currentMediaFiles;
    QString m_currentMediaTitle;
    QString m_currentMediaArtist;
    int m_currentPlaylistId;
};

#endif // APPSTATE_HPP