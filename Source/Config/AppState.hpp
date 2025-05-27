#ifndef APPSTATE_HPP
#define APPSTATE_HPP

#include <QObject>
#include <QVariantList>
#include <QSettings>

class AppState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentPlaylistName READ currentPlaylistName WRITE setCurrentPlaylistName NOTIFY currentPlaylistNameChanged)
    Q_PROPERTY(QVariantList currentMediaFiles READ currentMediaFiles WRITE setCurrentMediaFiles NOTIFY currentMediaFilesChanged)
    Q_PROPERTY(QString currentMediaTitle READ currentMediaTitle WRITE setCurrentMediaTitle NOTIFY currentMediaTitleChanged)
    Q_PROPERTY(QString currentMediaArtist READ currentMediaArtist WRITE setCurrentMediaArtist NOTIFY currentMediaArtistChanged)
    Q_PROPERTY(int currentPlaylistId READ currentPlaylistId WRITE setCurrentPlaylistId NOTIFY currentPlaylistIdChanged)
    Q_PROPERTY(bool isAuthenticated READ isAuthenticated NOTIFY authenticationChanged)
    Q_PROPERTY(QString email READ email WRITE setEmail NOTIFY emailChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString dateOfBirth READ dateOfBirth WRITE setDateOfBirth NOTIFY dateOfBirthChanged)
    Q_PROPERTY(QString role READ role WRITE setRole NOTIFY roleChanged)
    Q_PROPERTY(int userId READ userId WRITE setUserId NOTIFY userIdChanged)

public:
    static AppState *instance();
    QString currentPlaylistName() const;
    QVariantList currentMediaFiles() const;
    QString currentMediaTitle() const;
    QString currentMediaArtist() const;
    int currentPlaylistId() const;
    bool isAuthenticated() const;
    QString email() const;
    QString name() const;
    QString dateOfBirth() const;
    QString role() const;
    int userId() const;
    Q_INVOKABLE QString getToken() const;

public slots:
    void setCurrentPlaylistName(const QString &name);
    void setCurrentMediaFiles(const QVariantList &files);
    void setCurrentMediaTitle(const QString &title);
    void setCurrentMediaArtist(const QString &artist);
    void setCurrentPlaylistId(int id);
    void setState(const QVariantMap &state);
    void setEmail(const QString &email);
    void setName(const QString &name);
    void setDateOfBirth(const QString &dob);
    void setRole(const QString &role);
    void setUserId(int id);
    void loadUserInfo();
    void clearUserInfo();

signals:
    void currentPlaylistNameChanged();
    void currentMediaFilesChanged();
    void currentMediaTitleChanged();
    void currentMediaArtistChanged();
    void currentPlaylistIdChanged();
    void authenticationChanged();
    void emailChanged();
    void nameChanged();
    void dateOfBirthChanged();
    void roleChanged();
    void userIdChanged();

private:
    AppState(QObject *parent = nullptr);
    static AppState *m_instance;
    QString m_currentPlaylistName;
    QVariantList m_currentMediaFiles;
    QString m_currentMediaTitle;
    QString m_currentMediaArtist;
    int m_currentPlaylistId;
    QString m_email;
    QString m_name;
    QString m_dateOfBirth;
    QString m_role;
    bool m_isAuthenticated;
    int m_userId;
    QSettings *m_settings;
};

#endif // APPSTATE_HPP